---
name: edit-report
description: 修改既有報告時使用。界定什麼算「正文」不可動、什麼是結構修正可動，並說明結構修復的順序與驗證方式。
---

# 修改既有報告

## 先分清楚：正文 vs 結構

紅線 R1 禁止改「正文」，但結構修正不受限。界線如下：

| 可以動（結構） | 不可以動（正文，需使用者明確指名該篇） |
| --- | --- |
| 標題層級（H1→H2 等） | 敘述文字、論述、結論 |
| 標題的加粗、emoji、編號樣式 | **任何數值**——實驗數據、指標、耗時 |
| 檔名、圖檔名 | 表格內的數據 |
| 相對連結、圖片路徑 | 程式碼區塊內容 |
| 刪除重複標題 | 刪除任何段落 |
| 補上報告資訊區塊、摘要框架 | 憑推測填入摘要內容 |

灰色地帶一律當成正文，**先問再動**。

特別注意：補摘要時只能**建立空的段落結構**，不能自行歸納結論——歸納會引入模型的解讀，那是正文。要嘛請使用者填，要嘛明確標記 `<!-- TODO: 待補 -->`。

`files_without_summary` 這項指標只看「有沒有含摘要字樣的標題」，腳本無法判斷底下有沒有內容。**插入一個空的 `## 摘要` 讓指標歸零、卻不留 TODO 標記，等於規避關卡**，比不補更糟——之後沒有人會知道那裡還缺東西。補了結構就一定要留 `<!-- TODO: 待補 -->`。

## 結構修復的順序

一次只做一類，做完各自驗證。混在一起做，出問題時分不清是哪一步造成的。

### 第 1 步：重複 H1（指標 `dup_h1_files`）

Notion 匯出留下的頁標題 H1 與內文真標題並存。**保留內文的那個**（資訊較完整），刪掉匯出的頁標題。

```markdown
# 0729_training_report                          ← 刪這行（匯出頁標題）

# 柑橘病蟲害 YOLO26n-P2 模型訓練成效技術報告    ← 留這行
```

若兩個 H1 文字相同（`模型訓練數據報告.md` 就是這種），刪掉第一個即可。

### 第 2 步：標題層級（`heading_level_jumps`、`headings_deeper_than_h4`）

補上缺的中間層，或把過深的層級降級。**只改 `#` 的數量，不改標題文字。**

### 第 3 步：標題樣式（`bold_headings`、`emoji_headings`）

去掉包住整個標題的 `**`、去掉 emoji。標題文字本身保留。

```markdown
## **📱 4. 邊緣端實體硬體部署驗證**   →   ## 4. 邊緣端實體硬體部署驗證
```

### 第 4 步：編號（`cn_numbered_headings`、`duplicate_headings`）

「一、二、三」改成 `1.` `2.` `3.`。同層重號要重新編。

`duplicate_headings` 通常代表**內容真的重複貼了兩次**（`模型訓練數據報告.md` 的「混淆矩陣極端數據查證與分析」就是）。刪除重複段落屬於改正文 → **必須先問使用者**，不要自行判斷哪一份該留。

## 跨章搬移

若依 [`SPECIFICATION.md`](../../SPECIFICATION.md) §2 判斷某篇放錯章（例如 `RAG向量資料庫/效能測試 - 手機.md` 是實機數據，應屬〈系統測試與評估〉），這屬於跨目錄搬移，見 [`rename-files`](../rename-files/SKILL.md) 最下方——必須人工處理並先取得確認。

## 驗證

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/verify-links.ps1
powershell -ExecutionPolicy Bypass -File .agent/scripts/audit-structure.ps1 -Verbose
```

結構修復應該讓對應指標**下降**。確認下降後收緊基準線：

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/audit-structure.ps1 -UpdateBaseline
```

若某項指標上升，代表修 A 弄壞了 B（最常見：調整層級時造成新的跳級）。回去修，不要用 `-UpdateBaseline` 把劣化寫進基準線——那等於解除警報。
