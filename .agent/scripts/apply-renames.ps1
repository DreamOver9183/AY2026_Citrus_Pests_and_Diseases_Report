<#
.SYNOPSIS
  依對照表批次改名，並自動同步改寫全庫所有指向這些檔案的相對連結。
.DESCRIPTION
  改名而不改連結，是本 repo 最常見的破壞方式：本機看起來完全正常，
  推上 GitHub 才發現 404。本腳本把「改名 + 改連結 + 驗證」綁成單一原子操作。

  連結比對方式：把每條連結 percent-decode 後解析成絕對路徑，再與對照表比對。
  因此不受編碼寫法差異影響（%28 vs 字面 (、%20 vs +）。
  新連結一律以 Uri::EscapeDataString 逐段重新編碼，輸出統一格式。

  安全限制：
    - 只允許同目錄內改名。跨目錄搬移會連帶影響該檔自身的相對連結，
      風險較高，必須人工處理。
    - 目標檔名已存在時中止。
    - 一律使用 git mv 以保留檔案歷史。

.PARAMETER MapFile
  CSV 檔，需含 old,new 兩欄，路徑相對於 repo 根目錄。範例：

    old,new
    植物病蟲害辨識 (115資工四A)/病蟲害辨識模型/模型訓練數據報告/results 1.png,植物病蟲害辨識 (115資工四A)/病蟲害辨識模型/模型訓練數據報告/yolo26n_results.png

.PARAMETER WhatIf
  只列出將要發生的變更，不實際寫入。**第一次執行務必先加此參數。**

.EXAMPLE
  powershell -File .agent/scripts/apply-renames.ps1 -MapFile renames.csv -WhatIf
  powershell -File .agent/scripts/apply-renames.ps1 -MapFile renames.csv
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$MapFile,
    [switch]$WhatIf,
    [string]$Root = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '_common.ps1')

function Get-Abs { param([string]$P) return [System.IO.Path]::GetFullPath($P) }

function ConvertTo-EncodedPath {
    param([string]$RelPath)
    $parts = $RelPath -split '[\\/]' | Where-Object { $_ -ne '' }
    return ($parts | ForEach-Object { [System.Uri]::EscapeDataString($_) }) -join '/'
}

function Get-RelFrom {
    param([string]$FromDir, [string]$TargetAbs)
    $fromUri = New-Object System.Uri (($FromDir.TrimEnd('\', '/')) + [System.IO.Path]::DirectorySeparatorChar)
    $toUri   = New-Object System.Uri $TargetAbs
    return [System.Uri]::UnescapeDataString($fromUri.MakeRelativeUri($toUri).ToString())
}

# --- 讀取並驗證對照表 -------------------------------------------------------
if (-not (Test-Path -LiteralPath $MapFile)) { Write-Host "找不到對照表：$MapFile" -ForegroundColor Red; exit 1 }

$rows = Import-Csv -LiteralPath $MapFile -Encoding UTF8
if (-not $rows) { Write-Host '對照表是空的。' -ForegroundColor Red; exit 1 }
foreach ($c in 'old', 'new') {
    if ($rows[0].PSObject.Properties.Name -notcontains $c) {
        Write-Host "對照表缺少欄位：$c（需要 old,new）" -ForegroundColor Red; exit 1
    }
}

$errors = @()
$map = @{}   # oldAbs -> newAbs
foreach ($r in $rows) {
    if ([string]::IsNullOrWhiteSpace($r.old) -or [string]::IsNullOrWhiteSpace($r.new)) { continue }
    $oldAbs = Get-Abs (Join-Path $Root $r.old)
    $newAbs = Get-Abs (Join-Path $Root $r.new)

    if (-not (Test-Path -LiteralPath $oldAbs))          { $errors += "來源不存在：$($r.old)" ; continue }
    if ($map.ContainsKey($oldAbs))                      { $errors += "來源重複：$($r.old)" ; continue }
    if ($map.Values -contains $newAbs)                  { $errors += "目標重複：$($r.new)" ; continue }
    if ($oldAbs -eq $newAbs)                            { continue }
    if ((Test-Path -LiteralPath $newAbs))               { $errors += "目標已存在：$($r.new)" ; continue }
    if ((Split-Path -Parent $oldAbs) -ne (Split-Path -Parent $newAbs)) {
        $errors += "不允許跨目錄搬移（請人工處理）：$($r.old)"; continue
    }
    $newBase = Split-Path -Leaf $newAbs
    if ($newBase -match '[\s()（）]') { $errors += "目標檔名違反 N-1（含空格或括號）：$($r.new)" ; continue }
    if ([System.IO.Path]::GetFileNameWithoutExtension($newBase) -match '[\s_-]\d+$') {
        $errors += "目標檔名違反 N-4（流水號結尾）：$($r.new)"
    }
    $map[$oldAbs] = $newAbs
}

if ($errors.Count) {
    Write-Host ''
    Write-Host '對照表有問題，未執行任何變更：' -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}
if ($map.Count -eq 0) { Write-Host '對照表沒有需要處理的項目。' -ForegroundColor Yellow; exit 0 }

Write-Host ''
Write-Host "=== apply-renames ($($map.Count) 項) ===" -ForegroundColor Cyan
if ($WhatIf) { Write-Host '模式：WhatIf（不會寫入任何檔案）' -ForegroundColor Yellow }
Write-Host ''

# --- 改寫連結 ---------------------------------------------------------------
$rewriteCount = 0
$touchedFiles = @()

foreach ($file in Get-ChildItem -LiteralPath $Root -Recurse -File -Filter *.md) {
    $text = [System.IO.File]::ReadAllText($file.FullName)
    $masked = ConvertTo-FenceMasked $text   # 程式碼區塊內的範例連結不得改寫
    $edits = @()

    foreach ($mt in $LinkRegex.Matches($masked)) {
        $g = $mt.Groups['t']
        $target = $g.Value
        if ([string]::IsNullOrWhiteSpace($target) -or $SkipRegex.IsMatch($target)) { continue }

        $parts    = $target -split '#', 2
        $pathPart = $parts[0]
        $fragment = if ($parts.Count -gt 1) { '#' + $parts[1] } else { '' }
        if ([string]::IsNullOrWhiteSpace($pathPart)) { continue }

        $decoded = [System.Uri]::UnescapeDataString($pathPart)
        try { $abs = Get-Abs (Join-Path $file.DirectoryName $decoded) } catch { continue }

        if ($map.ContainsKey($abs)) {
            $newRel = Get-RelFrom -FromDir $file.DirectoryName -TargetAbs $map[$abs]
            $encoded = (ConvertTo-EncodedPath $newRel) + $fragment
            $edits += [PSCustomObject]@{ Index = $g.Index; Length = $g.Length; Value = $encoded }
        }
    }

    if ($edits.Count) {
        $rel = $file.FullName
        if ($rel.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
            $rel = $rel.Substring($Root.TrimEnd('\', '/').Length + 1)
        }
        Write-Host ("  改寫 {0,2} 條連結  {1}" -f $edits.Count, $rel)
        $rewriteCount += $edits.Count
        $touchedFiles += $rel

        if (-not $WhatIf) {
            foreach ($e in ($edits | Sort-Object Index -Descending)) {
                $text = $text.Remove($e.Index, $e.Length).Insert($e.Index, $e.Value)
            }
            [System.IO.File]::WriteAllText($file.FullName, $text, (New-Object System.Text.UTF8Encoding $false))
        }
    }
}
Write-Host ''
Write-Host ("連結改寫合計：{0} 條，涉及 {1} 個檔案" -f $rewriteCount, $touchedFiles.Count)
Write-Host ''

# --- 改名 -------------------------------------------------------------------
Push-Location $Root
try {
    foreach ($oldAbs in $map.Keys) {
        $newAbs = $map[$oldAbs]
        Write-Host ("  {0}  ->  {1}" -f (Split-Path -Leaf $oldAbs), (Split-Path -Leaf $newAbs))
        if (-not $WhatIf) {
            & git mv --  $oldAbs $newAbs
            if ($LASTEXITCODE -ne 0) {
                Write-Host "git mv 失敗，請檢查工作區狀態後手動還原。" -ForegroundColor Red
                exit 1
            }
        }
    }
} finally { Pop-Location }

if ($WhatIf) {
    Write-Host ''
    Write-Host 'WhatIf 結束，未寫入任何變更。確認無誤後移除 -WhatIf 重新執行。' -ForegroundColor Yellow
    exit 0
}

# --- 驗證 -------------------------------------------------------------------
Write-Host ''
Write-Host '--- 自動執行 verify-links ---' -ForegroundColor Cyan
& (Join-Path $PSScriptRoot 'verify-links.ps1')
$verifyExit = $LASTEXITCODE

if ($verifyExit -ne 0) {
    Write-Host ''
    Write-Host '改名已套用但驗證失敗。請勿 commit，先修好斷鏈。' -ForegroundColor Red
    Write-Host '要整批還原：git checkout -- . ; git reset' -ForegroundColor Yellow
    exit 1
}

Write-Host ''
Write-Host '改名與連結改寫完成，驗證通過。接著執行 audit-structure.ps1 再 commit。' -ForegroundColor Green
exit 0
