# 共用函式。由 verify-links.ps1 / apply-renames.ps1 / audit-structure.ps1 dot-source 使用。

# .NET Framework (PowerShell 5.1) 沒有 [System.IO.Path]::GetRelativePath，自行實作
function Get-RelPath {
    param([string]$Base, [string]$Full)
    $b = $Base.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if ($Full.StartsWith($b, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $Full.Substring($b.Length)
    }
    return $Full
}

<#
把 ``` 圍起來的程式碼區塊內容換成等量空白，並保留原本的字元位置。

用途：文件裡常有「範例連結」寫在程式碼區塊中（AGENTS.md、各 SKILL.md 都有）。
那些不是真連結，不該被當成斷鏈，更不該被 apply-renames 改寫。
遮罩後長度與偏移量完全不變，因此 regex 比對的 Index 仍可直接套用在原文上。
#>
function ConvertTo-FenceMasked {
    param([string]$Text)

    $sb = New-Object System.Text.StringBuilder $Text.Length
    $inFence = $false
    $pos = 0

    while ($pos -lt $Text.Length) {
        $nl = $Text.IndexOf("`n", $pos)
        if ($nl -lt 0) { $nl = $Text.Length } else { $nl = $nl + 1 }
        $line = $Text.Substring($pos, $nl - $pos)

        $isFenceMarker = $line -match '^\s*```'
        if ($isFenceMarker -or $inFence) {
            foreach ($ch in $line.ToCharArray()) {
                if ($ch -eq "`n" -or $ch -eq "`r") { [void]$sb.Append($ch) }
                else { [void]$sb.Append(' ') }
            }
        } else {
            [void]$sb.Append($line)
        }
        if ($isFenceMarker) { $inFence = -not $inFence }

        $pos = $nl
    }

    return $sb.ToString()
}

# ](target)：允許 target 內有一層成對括號，例如 提示詞(Prompt).md
$script:LinkRegex = [regex]'(?<img>!)?\[[^\]]*\]\((?<t>[^()]*(?:\([^()]*\)[^()]*)*)\)'
$script:SkipRegex = [regex]'^(https?:|mailto:|about:|#)'
