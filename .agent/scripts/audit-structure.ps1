<#
.SYNOPSIS
  盤點報告的結構、標題與檔名是否符合 README「報告撰寫規範」，並以棘輪機制防止劣化。
.DESCRIPTION
  掃描範圍只含報告本體（植物病蟲害辨識 (115資工四A)/ 底下），
  不含 README.md、AGENTS.md 等後設文件。

  所有指標都是「越低越好」。預設模式會與 .agent/baseline.json 比對：
    - 任何一項數字「上升」  -> exit 1（本次變更讓報告變糟，不得 commit）
    - 數字持平或下降        -> exit 0
  既有問題不必一次修完，但不允許新增。

  修好一批問題後，用 -UpdateBaseline 把基準線往下收緊。
.PARAMETER UpdateBaseline
  以本次掃描結果覆寫 baseline.json。只有在數字下降時才應執行。
.EXAMPLE
  pwsh -File .agent/scripts/audit-structure.ps1
  pwsh -File .agent/scripts/audit-structure.ps1 -UpdateBaseline
#>
[CmdletBinding()]
param(
    [switch]$UpdateBaseline,
    [string]$Root
)

$ErrorActionPreference = 'Stop'

# PS 5.1 的 [CmdletBinding()] 會讓 $PSScriptRoot 在 param() 預設值運算式內為空字串，
# 導致 Split-Path 繫結失敗、腳本還沒開始跑就 exit 1。本體內的 $PSScriptRoot 正常，
# 所以改在這裡解析。
# 不要 fallback 到 $PWD：工作目錄不對時會靜默掃錯範圍並回報 PASS，比直接失敗更危險。
if (-not $Root) { $Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot) }

. (Join-Path $PSScriptRoot '_common.ps1')

$reportDir   = Join-Path $Root '植物病蟲害辨識 (115資工四A)'
$baselineFile = Join-Path (Split-Path -Parent $PSScriptRoot) 'baseline.json'

if (-not (Test-Path -LiteralPath $reportDir)) {
    Write-Host "找不到報告目錄：$reportDir" -ForegroundColor Red
    exit 1
}

# --- 取出標題（略過程式碼區塊內的 # 行）-------------------------------------
function Get-Headings {
    param([string]$Path)
    $inFence = $false
    $result = @()
    foreach ($line in [System.IO.File]::ReadAllLines($Path)) {
        if ($line -match '^\s*```') { $inFence = -not $inFence; continue }
        if ($inFence) { continue }
        if ($line -match '^(#{1,6})\s+(.*)$') {
            $result += [PSCustomObject]@{
                Level = $Matches[1].Length
                Text  = $Matches[2].TrimEnd()
            }
        }
    }
    return $result
}

$emojiRx = [regex]'[\uD800-\uDBFF][\uDC00-\uDFFF]|[←-⇿⌀-➿⬀-⯿️]'

$m = [ordered]@{
    dup_h1_files              = 0   # H-1 一檔多個 H1
    heading_level_jumps       = 0   # H-2 標題跳級
    headings_deeper_than_h4   = 0   # H-3 超過 H4
    bold_headings             = 0   # H-4 標題整段加粗
    emoji_headings            = 0   # H-4 標題含 emoji
    cn_numbered_headings      = 0   # H-5 中文數字編號
    duplicate_headings        = 0   # H-5 同檔重複標題
    files_without_summary     = 0   # 骨架 #4 缺摘要
    filename_with_space       = 0   # N-1 檔名含空格
    filename_with_paren       = 0   # N-1 檔名含括號
    image_serial_suffix       = 0   # N-4 圖檔流水號結尾
    image_placeholder_name    = 0   # 5.3 匯出工具亂碼檔名
    image_uuid_name           = 0   # 5.3 UUID 檔名
}
$details = @{}
foreach ($k in $m.Keys) { $details[$k] = @() }

function Add-Hit { param($Key, $Item) $script:m[$Key]++; $script:details[$Key] += $Item }

# --- 掃描 md ----------------------------------------------------------------
foreach ($file in Get-ChildItem -LiteralPath $reportDir -Recurse -File -Filter *.md) {
    $rel = Get-RelPath -Base $Root -Full $file.FullName
    $headings = Get-Headings -Path $file.FullName

    $h1 = @($headings | Where-Object Level -eq 1)
    if ($h1.Count -gt 1) { Add-Hit dup_h1_files "$rel ($($h1.Count) 個 H1)" }

    $prev = 0
    foreach ($h in $headings) {
        if ($prev -gt 0 -and ($h.Level - $prev) -gt 1) {
            Add-Hit heading_level_jumps "$rel  H$prev->H$($h.Level): $($h.Text)"
        }
        $prev = $h.Level

        if ($h.Level -gt 4)              { Add-Hit headings_deeper_than_h4 "$rel  $($h.Text)" }
        if ($h.Text -match '^\*\*')      { Add-Hit bold_headings           "$rel  $($h.Text)" }
        if ($emojiRx.IsMatch($h.Text))   { Add-Hit emoji_headings          "$rel  $($h.Text)" }
        if ($h.Text -match '^[一二三四五六七八九十]+、') {
            Add-Hit cn_numbered_headings "$rel  $($h.Text)"
        }
    }

    $dupText = $headings | Group-Object { "$($_.Level)|$($_.Text)" } | Where-Object Count -gt 1
    foreach ($d in $dupText) {
        Add-Hit duplicate_headings "$rel  x$($d.Count): $($d.Group[0].Text)"
    }

    if (-not ($headings | Where-Object { $_.Text -match '摘要|總覽|概述|Overview|Summary' })) {
        Add-Hit files_without_summary $rel
    }

    $base = $file.BaseName
    if ($base -match '\s')       { Add-Hit filename_with_space $rel }
    if ($base -match '[()（）]') { Add-Hit filename_with_paren $rel }
}

# --- 掃描圖檔 ---------------------------------------------------------------
foreach ($img in Get-ChildItem -LiteralPath $reportDir -Recurse -File |
                 Where-Object { $_.Extension -in '.png', '.jpg', '.jpeg', '.gif', '.webp' }) {
    $rel  = Get-RelPath -Base $Root -Full $img.FullName
    $base = $img.BaseName
    if ($base -match '\s\d+$')            { Add-Hit image_serial_suffix    $rel }
    if ($base -match '^imported-image')   { Add-Hit image_placeholder_name $rel }
    if ($base -match '^images?[0-9a-f]{8}') { Add-Hit image_uuid_name      $rel }
}

# --- 輸出 -------------------------------------------------------------------
$hasBaseline = Test-Path -LiteralPath $baselineFile
$baseline = if ($hasBaseline) {
    Get-Content -LiteralPath $baselineFile -Raw -Encoding UTF8 | ConvertFrom-Json
} else { $null }

Write-Host ''
Write-Host '=== audit-structure ===' -ForegroundColor Cyan
Write-Host ''

$worse = @()
$better = @()
$rows = foreach ($k in $m.Keys) {
    $now = $m[$k]
    $was = if ($baseline -and ($baseline.PSObject.Properties.Name -contains $k)) { [int]$baseline.$k } else { $null }
    $delta = if ($null -ne $was) { $now - $was } else { $null }
    if ($null -ne $delta) {
        if ($delta -gt 0) { $worse  += "$k  $was -> $now  (+$delta)" }
        if ($delta -lt 0) { $better += "$k  $was -> $now  ($delta)" }
    }
    [PSCustomObject]@{
        '指標'   = $k
        '基準'   = if ($null -ne $was) { $was } else { '-' }
        '現在'   = $now
        '變化'   = if ($null -eq $delta) { 'n/a' } elseif ($delta -gt 0) { "+$delta" } elseif ($delta -lt 0) { "$delta" } else { '=' }
    }
}
$rows | Format-Table -AutoSize | Out-String | Write-Host

if ($VerbosePreference -eq 'Continue') {
    foreach ($k in $m.Keys) {
        if ($details[$k].Count) {
            Write-Host "--- $k ---" -ForegroundColor DarkGray
            $details[$k] | ForEach-Object { Write-Host "    $_" }
        }
    }
    Write-Host ''
}

if ($UpdateBaseline) {
    ($m | ConvertTo-Json) | Set-Content -LiteralPath $baselineFile -Encoding UTF8
    Write-Host "基準線已更新：$baselineFile" -ForegroundColor Green
    exit 0
}

if (-not $hasBaseline) {
    Write-Host '尚無基準線。請先執行： -UpdateBaseline' -ForegroundColor Yellow
    exit 0
}

if ($better.Count) {
    Write-Host '改善：' -ForegroundColor Green
    $better | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
    Write-Host ''
}

if ($worse.Count) {
    Write-Host '劣化（本次變更新增了違規）：' -ForegroundColor Red
    $worse | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    Write-Host ''
    Write-Host 'FAIL - 不得 commit。用 -Verbose 看逐項清單。' -ForegroundColor Red
    exit 1
}

Write-Host 'PASS - 沒有新增違規' -ForegroundColor Green
if ($better.Count) {
    Write-Host '（已有改善，可執行 -UpdateBaseline 收緊基準線）' -ForegroundColor Yellow
}
exit 0
