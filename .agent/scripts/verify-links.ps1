<#
.SYNOPSIS
  硬性關卡：檢查全庫 md 的相對連結與圖片是否全部指向存在的檔案。
.DESCRIPTION
  任何改名、搬移、改寫連結的作業完成後都必須執行本腳本。
  斷鏈數不為 0 時以 exit code 1 結束，代表該次變更不得 commit。

  程式碼區塊與行內程式碼內的範例連結會被略過，不列入檢查。

  注意：percent-decode 一律使用 [System.Uri]::UnescapeDataString()。
  本機 Git Bash 的 printf '%b' 不支援 \xHH，用 bash 解碼會靜默失敗、
  把全部連結誤判為斷鏈。
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .agent/scripts/verify-links.ps1
#>
[CmdletBinding()]
param(
    [string]$Root
)

$ErrorActionPreference = 'Stop'

# PS 5.1 的 [CmdletBinding()] 會讓 $PSScriptRoot 在 param() 預設值運算式內為空字串，
# 導致 Split-Path 繫結失敗、腳本還沒開始跑就 exit 1。本體內的 $PSScriptRoot 正常，
# 所以改在這裡解析。
# 不要 fallback 到 $PWD：工作目錄不對時會靜默掃錯範圍並回報 PASS，比直接失敗更危險。
if (-not $Root) { $Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot) }

. (Join-Path $PSScriptRoot '_common.ps1')

$total = 0; $images = 0; $broken = @()

# 排除 .git/ 下可能殘留的 md（例如 merge conflict 遺留物）
$gitPath = [System.IO.Path]::DirectorySeparatorChar + '.git' + [System.IO.Path]::DirectorySeparatorChar
$mdFiles = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter *.md |
           Where-Object { -not $_.FullName.Contains($gitPath) }

foreach ($file in $mdFiles) {
    $masked = ConvertTo-FenceMasked ([System.IO.File]::ReadAllText($file.FullName))

    foreach ($m in $LinkRegex.Matches($masked)) {
        $target = $m.Groups['t'].Value
        if ([string]::IsNullOrWhiteSpace($target)) { continue }
        if ($SkipRegex.IsMatch($target)) { continue }

        $path = ($target -split '#')[0]
        if ([string]::IsNullOrWhiteSpace($path)) { continue }

        $decoded = [System.Uri]::UnescapeDataString($path)

        $total++
        if ($m.Groups['img'].Success) { $images++ }

        # 含非法路徑字元的目標會讓 Join-Path / Test-Path 拋例外。
        # 視為斷鏈回報即可，不要讓單一壞連結中斷整輪掃描。
        $exists = $false
        try {
            $resolved = Join-Path $file.DirectoryName $decoded
            $exists = Test-Path -LiteralPath $resolved
        } catch {
            $exists = $false
        }

        if (-not $exists) {
            $broken += [PSCustomObject]@{
                Source = Get-RelPath -Base $Root -Full $file.FullName
                Target = $decoded
                Kind   = if ($m.Groups['img'].Success) { 'image' } else { 'link' }
            }
        }
    }
}

Write-Host ''
Write-Host '=== verify-links ===' -ForegroundColor Cyan
Write-Host ("  本機連結總數 : {0}" -f $total)
Write-Host ("  其中圖片     : {0}" -f $images)

if ($broken.Count -eq 0) {
    Write-Host "  斷鏈         : 0" -ForegroundColor Green
    Write-Host ''
    Write-Host 'PASS - 可以 commit' -ForegroundColor Green
    exit 0
}

Write-Host ("  斷鏈         : {0}" -f $broken.Count) -ForegroundColor Red
Write-Host ''
$broken | Format-Table -AutoSize | Out-String | Write-Host
Write-Host 'FAIL - 修好斷鏈之前不得 commit' -ForegroundColor Red
Write-Host '常見原因：檔案改名後沒有同步改寫指向它的相對連結。' -ForegroundColor Yellow
exit 1
