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

# 整行換成等量空白（換行字元保留，維持偏移量）
function Get-BlankedLine {
    param([string]$Line)
    $chars = $Line.ToCharArray()
    for ($i = 0; $i -lt $chars.Length; $i++) {
        if ($chars[$i] -ne "`r" -and $chars[$i] -ne "`n") { $chars[$i] = ' ' }
    }
    return (-join $chars)
}

<#
遮罩行內程式碼 `...`。

N 個反引號開啟，必須由「恰好 N 個」反引號收尾（Markdown 規則）。
找不到收尾就當一般文字，不遮。
#>
function Get-InlineCodeMasked {
    param([string]$Line)
    $chars = $Line.ToCharArray()
    $i = 0
    while ($i -lt $chars.Length) {
        if ($chars[$i] -ne '`') { $i++; continue }

        $openStart = $i
        while ($i -lt $chars.Length -and $chars[$i] -eq '`') { $i++ }
        $n = $i - $openStart

        $j = $i
        $found = $false
        while ($j -lt $chars.Length) {
            if ($chars[$j] -ne '`') { $j++; continue }
            $runStart = $j
            while ($j -lt $chars.Length -and $chars[$j] -eq '`') { $j++ }
            if (($j - $runStart) -eq $n) { $found = $true; break }
        }
        if (-not $found) { continue }

        for ($k = $openStart; $k -lt $j; $k++) {
            if ($chars[$k] -ne "`r" -and $chars[$k] -ne "`n") { $chars[$k] = ' ' }
        }
        $i = $j
    }
    return (-join $chars)
}

<#
把程式碼區塊與行內程式碼的內容換成等量空白，並保留原本的字元位置。

用途：文件裡常有「範例連結」寫在程式碼中（AGENTS.md、各 SKILL.md 都有）。
那些不是真連結，不該被當成斷鏈，更不該被 apply-renames 改寫。
遮罩後長度與偏移量完全不變，因此 regex 比對的 Index 仍可直接套用在原文上。

兩種都要遮：
  - 圍欄區塊：記錄開圍欄的反引號數量 N，只有 >= N 的圍欄標記才關閉。
    四反引號包三反引號的巢狀範例若不這樣處理，狀態會從第二行起完全顛倒。
  - 行內程式碼：文件討論 Markdown 語法時，常把連結寫在行內反引號裡
    （例如帶標題屬性的寫法），不遮的話會被解析成真連結而誤報或崩潰。
#>
function ConvertTo-FenceMasked {
    param([string]$Text)

    $sb = New-Object System.Text.StringBuilder $Text.Length
    $fenceLen = 0   # 0 = 不在圍欄內；>0 = 開圍欄的反引號數量
    $pos = 0

    while ($pos -lt $Text.Length) {
        $nl = $Text.IndexOf("`n", $pos)
        if ($nl -lt 0) { $nl = $Text.Length } else { $nl = $nl + 1 }
        $line = $Text.Substring($pos, $nl - $pos)

        $marker = [regex]::Match($line, '^\s*(`{3,})')
        $markerLen = if ($marker.Success) { $marker.Groups[1].Value.Length } else { 0 }

        if ($markerLen -gt 0 -or $fenceLen -gt 0) {
            [void]$sb.Append((Get-BlankedLine $line))
        } else {
            [void]$sb.Append((Get-InlineCodeMasked $line))
        }

        if ($markerLen -gt 0) {
            if ($fenceLen -eq 0) { $fenceLen = $markerLen }
            elseif ($markerLen -ge $fenceLen) { $fenceLen = 0 }
        }

        $pos = $nl
    }

    return $sb.ToString()
}

# ](target "選用標題")
#   - target 不含空白（Markdown 的裸目標本來就不允許未跳脫空白），允許一層成對括號
#   - 標題屬性（"..." / '...'）只作為結尾的可選部分吞掉，不進 t 群組，
#     否則 Test-Path 會拿到含引號的非法路徑而拋出例外
$script:LinkRegex = [regex]'(?<img>!)?\[[^\]]*\]\(\s*(?<t>[^()\s]*(?:\([^()]*\)[^()\s]*)*)(?:\s+[^()]*)?\s*\)'
$script:SkipRegex = [regex]'^(https?:|file:|mailto:|about:|#)'
