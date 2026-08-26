---
name: rename-files
description: 改報告或圖檔的檔名、整理命名時使用。涵蓋語意推導、對照表產出、連結同步改寫與驗證。任何改名作業都必須走這個流程，不得直接 mv 或 rename。
---

# 改名與命名整理

## 什麼時候用

改任何 `.md` 或圖檔的檔名、批次整理命名。**不含**跨目錄搬移（見最下方）。

## 絕對前提

改名的難點不是「改成什麼樣子」，而是：

1. **改名必須連帶改寫所有指向它的相對連結。** 漏掉的話本機完全正常，推上 GitHub 才 404。
2. **正確的新名字要從內容推，不能從舊名字推。** 見 [`AGENTS.md`](../../../AGENTS.md) 的「語意優先於規則」。

這兩件事都由 `apply-renames.ps1` 處理。**不要自己 `git mv`、不要自己改連結。**

## 流程

### 1. 盤點

列出這次要處理的檔案，以及各自違反哪條規範（規範見 [`README.md`](../../../README.md) §5）。

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/audit-structure.ps1 -Verbose
```

`filename_with_space`、`filename_with_paren`、`image_serial_suffix`、`image_placeholder_name`、`image_uuid_name` 這幾項的逐項清單就是工作範圍。

### 2. 推語意（這一步不可跳過）

對每個檔案，找出它在 md 裡被引用的位置，讀**前後文**判斷它實際是什麼。

```powershell
# 找出某張圖被誰引用、在哪一行
Select-String -Path "植物病蟲害辨識 (115資工四A)\*.md" -Recurse -Pattern "results%201" -Encoding UTF8

# 看引用點上下文（含所屬章節標題）
$f = "植物病蟲害辨識 (115資工四A)\病蟲害辨識模型\模型訓練數據報告.md"
Get-Content -LiteralPath $f -Encoding UTF8 | Select-Object -Skip 180 -First 40
```

判斷依據優先序：

1. 引用點所屬的**章節標題**（最可靠，例如 `### 2. YOLO26-nano 詳細訓練軌跡`）
2. 圖片的 alt text 與緊鄰的說明文字
3. 同資料夾其他檔案的命名邏輯

**推不出來就停下來問使用者，不要猜。** 猜錯的檔名比原本的爛檔名更糟——爛檔名至少誠實。

### 3. 產出對照表

寫成 CSV，路徑相對於 repo 根目錄，欄位固定 `old,new`：

```csv
old,new
植物病蟲害辨識 (115資工四A)/病蟲害辨識模型/模型訓練數據報告/results 1.png,植物病蟲害辨識 (115資工四A)/病蟲害辨識模型/模型訓練數據報告/yolo26n_results.png
```

新檔名必須符合 [`README.md`](../../../README.md) §5.2（報告）或 §5.3（圖檔），模型代號取自 §5.4 名詞統一表。

存檔用 **UTF-8 with BOM**，否則 `Import-Csv` 會讀成亂碼。

### 4. 交使用者確認

改名不可逆且牽動連結，**對照表必須先給使用者過目再執行**。列出時標明每一項的語意依據（來自哪個章節標題），讓對方能快速抓錯。

### 5. 試跑

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/apply-renames.ps1 -MapFile renames.csv -WhatIf
```

檢查輸出：改名清單對不對、連結改寫的條數是否合理（每張圖至少 1 條；若某檔顯示 0 條連結被改寫，代表它根本沒被引用，要先確認是不是孤兒檔）。

### 6. 執行

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/apply-renames.ps1 -MapFile renames.csv
```

腳本會：改寫連結 → `git mv` → 自動跑 `verify-links.ps1`。任一步失敗就中止。

### 7. 收尾

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/audit-structure.ps1
```

改名應該讓 `filename_*` / `image_*` 指標**下降**。確認下降後可收緊基準線：

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/audit-structure.ps1 -UpdateBaseline
```

然後依 [`commit-and-push`](../commit-and-push/SKILL.md) 提交。

## 常見錯誤

| 錯誤 | 後果 |
| --- | --- |
| 把 `results 1.png` 改成 `results_1.png` | 規則過了、缺陷還在。腳本會以 N-4 擋下 |
| 用 `mv` / `Rename-Item` 而非腳本 | 連結沒改，GitHub 上 404 |
| 用 `Rename-Item` 而非 `git mv` | 檔案歷史斷掉 |
| CSV 存成無 BOM 的 UTF-8 | `Import-Csv` 讀出亂碼路徑，全數比對失敗 |
| 沒跑 `-WhatIf` 就直接執行 | 錯了要整批還原：`git checkout -- . ; git reset` |

## 跨目錄搬移

腳本**刻意不支援**。搬到別的資料夾會同時改變該檔自身所有外送連結的相對深度，風險高於一般改名。

若確有需要（例如依 [`README.md`](../../../README.md) §2 職責界線把 `效能測試 - 手機.md` 從〈RAG向量資料庫〉移到〈系統測試與評估〉），必須：

1. 明確告知使用者這會動到該篇自身的連結與兩章的索引頁
2. 取得確認後人工處理
3. 完成後 `verify-links.ps1` 斷鏈必須為 0
