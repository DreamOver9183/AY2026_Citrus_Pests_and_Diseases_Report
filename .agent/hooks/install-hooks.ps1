<#
.SYNOPSIS
  安裝本 repo 納入版控的 git hooks。
.DESCRIPTION
  把 core.hooksPath 指向 .agent/hooks，使 pre-commit 生效。
  hook 放在版控裡（.git/hooks 不進版控），每位成員 clone 後各自執行一次。

  解除：git config --unset core.hooksPath
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .agent/hooks/install-hooks.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# PS 5.1 的 [CmdletBinding()] 會讓 $PSScriptRoot 在 param() 預設值內為空，故在本體解析。
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Push-Location $root
try {
    $existing = & git config --local core.hooksPath
    if ($existing -and $existing -ne '.agent/hooks') {
        Write-Host "core.hooksPath 目前指向 $existing，將覆寫為 .agent/hooks" -ForegroundColor Yellow
    }

    & git config --local core.hooksPath '.agent/hooks'
    if ($LASTEXITCODE -ne 0) { Write-Host '設定失敗。' -ForegroundColor Red; exit 1 }

    Write-Host ''
    Write-Host 'pre-commit hook 已啟用。' -ForegroundColor Green
    Write-Host '  每次 git commit 會先跑 verify-links 與 audit-structure，任一失敗就擋下。'
    Write-Host ''
    Write-Host '注意：git commit --no-verify 會跳過本 hook，等同違反 AGENTS.md 紅線 R5。' -ForegroundColor Yellow
    Write-Host '解除安裝：git config --unset core.hooksPath'
    exit 0
} finally { Pop-Location }
