---
name: delete-report
description: 刪除或歸檔既有報告時使用。涵蓋刪除前的引用盤點、資產資料夾連帶清理、章導覽移除與驗證。刪報告最常見的殘留是同名 Image/ 資料夾與章導覽裡的那一行。
---

# 刪除一篇報告

## 什麼時候用

某篇報告重複、過時或經判斷不該留在報告庫。**不含**搬到別章（那是跨目錄搬移，見 [`rename-files`](../rename-files/SKILL.md) 最下方）。

## 絕對前提

刪除是不可逆的內容變更，屬於紅線 R1 的範圍。

**必須由使用者明確指名要刪哪一篇並確認。** Agent 不得自行判斷某篇「重複」或「過時」就動手——那是研究產出的取捨，不是結構整理。

## 流程

### 1. 盤點誰引用了它

```powershell
$name = "yolo26n_p2_v2_vs_v3_comparison"
Select-String -Path "植物病蟲害辨識 (115資工四A)\*.md" -Recurse -Pattern $name -Encoding UTF8
```

中文檔名要連 percent-encoded 的寫法一起找（連結是編碼過的，檔名字面搜不到）：

```powershell
[System.Uri]::EscapeDataString("架構設計")
```

把結果分成三類，逐類處理：

| 引用來源 | 怎麼處理 |
| --- | --- |
| 章導覽 `README.md` 的該章區塊 | 刪掉那一行 |
| 其他 L2 報告的正文 | **改連結屬結構修正、刪整段屬正文**。若刪掉後句子讀不通，停下來問使用者要改寫成什麼 |
| 根 `README.md` | 通常不會直接指到 L2；若有，一併處理 |

### 2. 連帶清掉資產資料夾

§1 規定資產資料夾與報告同名。刪報告一定要連它一起刪：

```powershell
植物病蟲害辨識 (115資工四A)/<章名>/Image/<篇名>/
```

漏刪的話圖片會變成孤兒，`orphan_images` 指標會抓到（見第 4 步）。

### 3. 用 git rm 刪除

```powershell
git rm "植物病蟲害辨識 (115資工四A)/<章名>/<篇名>.md"
git rm -r "植物病蟲害辨識 (115資工四A)/<章名>/Image/<篇名>"
```

用 `git rm` 而不是 `Remove-Item`，檔案歷史才留得住。

### 4. 驗證

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/verify-links.ps1
powershell -ExecutionPolicy Bypass -File .agent/scripts/audit-structure.ps1 -Verbose
```

這一步是刪除流程的重點，兩支腳本分別擋住兩種漏刪：

| 症狀 | 代表什麼 |
| --- | --- |
| `verify-links` 出現斷鏈 | 有連結還指向被刪的檔案，第 1 步沒做完 |
| `orphan_images` 上升 | 資產資料夾沒刪乾淨，第 2 步沒做完 |

指標**下降**（例如該篇原本就有結構問題）才可收緊基準線：

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/audit-structure.ps1 -UpdateBaseline
```

然後依 [`commit-and-push`](../commit-and-push/SKILL.md) 提交。CHANGELOG 的「範圍」寫 `內容`，摘要要寫清楚**為什麼刪**——這是之後唯一能回溯判斷依據的地方。

## 常見錯誤

| 錯誤 | 後果 |
| --- | --- |
| 只刪 md、留下 `Image/<篇名>/` | 孤兒圖永遠留在 repo，`orphan_images` 上升 |
| 忘了從章導覽 `README.md` 移除那一行 | `verify-links` 直接報斷鏈 |
| 用 `Remove-Item` 而非 `git rm` | 檔案歷史斷掉 |
| Agent 自行判斷「這篇重複」就刪 | 違反紅線 R1。刪哪一篇是使用者的決定 |
