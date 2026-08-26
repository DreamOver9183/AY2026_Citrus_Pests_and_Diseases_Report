<#
.SYNOPSIS
  硬性關卡：檢查全庫 md 的相對連結與圖片是否全部指向存在的檔案。
.DESCRIPTION
  任何改名、搬移、改寫連結的作業完成後都必須執行本腳本。
  斷鏈數不為 0 時以 exit code 1 結束，代表該次變更不得 commit。

  程式碼區塊（```）內的範例連結會被略過，不列入檢查。

  注意：percent-decode 一律使用 [System.Uri]::UnescapeDataString()。
  本機 Git Bash 的 printf '%b' 不支援 \xHH，用 bash 解碼會靜默失敗、
  把全部連結誤判為斷鏈。
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .agent/scripts/verify-links.ps1
#>
[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '_common.ps1')

$total = 0; $images = 0; $broken = @()

foreach ($file in Get-ChildItem -LiteralPath $Root -Recurse -File -Filter *.md) {
    $masked = ConvertTo-FenceMasked ([System.IO.File]::ReadAllText($file.FullName))

    foreach ($m in $LinkRegex.Matches($masked)) {
        $target = $m.Groups['t'].Value
        if ([string]::IsNullOrWhiteSpace($target)) { continue }
        if ($SkipRegex.IsMatch($target)) { continue }

        $path = ($target -split '#')[0]
        if ([string]::IsNullOrWhiteSpace($path)) { continue }

        $decoded  = [System.Uri]::UnescapeDataString($path)
        $resolved = Join-Path $file.DirectoryName $decoded

        $total++
        if ($m.Groups['img'].Success) { $images++ }

        if (-not (Test-Path -LiteralPath $resolved)) {
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