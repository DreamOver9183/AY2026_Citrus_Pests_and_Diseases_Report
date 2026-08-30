# AGENTS.md

本檔是所有 AI agent 操作此 repo 的**唯一入口**，不分廠商。動手前先讀完，再依「任務路由」載入對應 skill。

## 這是什麼

柑橘病蟲害辨識專題的**研究報告庫**，不是程式專案。內容是 25 篇 Markdown 報告 + 48 張圖表，全部由 Notion 匯出後整理而成。沒有建置流程、沒有測試套件；這裡的「正確性」指的是**結構規範**與**連結完整性**。

## 紅線（任何情況都不得跨越）

| # | 禁止 | 原因 |
| --- | --- | --- |
| R1 | 修改 `植物病蟲害辨識 (115資工四A)/` 底下任何報告的**正文**，除非使用者明確指名該篇並要求改內容 | 這是研究數據，不是可重構的程式碼。改檔名、改連結、改標題層級都不算改正文；改敘述、改數字、改結論算 |
| R2 | `git push --force`、`git rebase`、改寫已推送的歷史 | 遠端是團隊共用 |
| R3 | 把 `參考文獻與參考資料/` 下的第三方論文 PDF 加入版控 | 版權。`.gitignore` 已排除，唯一例外是團隊內部文件 `一站式平臺服務應用規劃.pdf` |
| R4 | 用純機械規則批次改檔名 | 見下方「語意優先」 |
| R5 | 在驗證未通過的情況下 commit | 見下方「收工關卡」 |

## 語意優先於規則

規範是用來判斷「對不對」，不是用來自動生成答案。最典型的陷阱：

`模型訓練數據報告/` 裡有 `results.png`、`results 1.png`、`results 2.png`、`results 3.png`。
規範說「檔名不得含空格」——照字面執行會改成 `results_1.png`，規則通過了，但**缺陷原封不動**。

這四張圖其實分屬四個不同模型。正確名稱只能從 md 裡的段落標題反推：

| 引用位置的章節 | 檔案 | 正確名稱 |
| --- | --- | --- |
| `### 1. YOLO26-large 詳細訓練軌跡` | `results.png` | `yolo26l_results.png` |
| `### 2. YOLO26-nano 詳細訓練軌跡` | `results 1.png` | `yolo26n_results.png` |
| `### 3. YOLO26-nano+P2 詳細訓練軌跡` | `results 2.png` | `yolo26n_p2_results.png` |
| `### 4. YOLO26-nano-p2-w8a32 詳細訓練軌跡` | `results 3.png` | `yolo26n_p2_w8a32_results.png` |

**規則：任何改名前，必須先讀該檔案被引用處的上下文，確認它實際是什麼。推不出來就停下來問，不要猜。**

## 收工關卡

任何變更 commit 前，兩支腳本都必須通過。這是硬性要求，不是建議。

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/verify-links.ps1
powershell -ExecutionPolicy Bypass -File .agent/scripts/audit-structure.ps1
```

| 腳本 | 檢查 | 通過條件 |
| --- | --- | --- |
| `verify-links.ps1` | 全庫相對連結與圖片是否指向存在的檔案 | 斷鏈 **必須為 0** |
| `audit-structure.ps1` | 13 項結構／標題／檔名指標，與 `.agent/baseline.json` 比對 | 任何一項**都不得上升** |

`audit-structure.ps1` 採**棘輪機制**：既有問題不必一次修完，但不允許新增。修好一批後才執行 `-UpdateBaseline` 收緊基準線。用 `-Verbose` 可列出逐項清單。

兩支腳本 exit code 非 0 就是不得 commit。**不要以「我檢查過了」代替實際執行。**

## 異動紀錄

這是團隊共用 repo，**任何人或 agent 的每一次 commit，都必須在 [`CHANGELOG.md`](CHANGELOG.md) 新增一筆固定格式的紀錄**，寫在檔案最上方，不覆寫舊條目。欄位定義、範本、與寫入時機見 [`CHANGELOG.md`](CHANGELOG.md) 本身與 [`.agent/skills/commit-and-push/SKILL.md`](.agent/skills/commit-and-push/SKILL.md)。

## 任務路由

| 你要做的事 | 載入 |
| --- | --- |
| 改檔名／搬移檔案／整理命名 | [`.agent/skills/rename-files/SKILL.md`](.agent/skills/rename-files/SKILL.md) |
| 新增一篇報告 | [`.agent/skills/add-report/SKILL.md`](.agent/skills/add-report/SKILL.md) |
| 修改既有報告的結構或內容 | [`.agent/skills/edit-report/SKILL.md`](.agent/skills/edit-report/SKILL.md) |
| commit 與推送 | [`.agent/skills/commit-and-push/SKILL.md`](.agent/skills/commit-and-push/SKILL.md) |

規範本體在 [`.agent/SPECIFICATION.md`](.agent/SPECIFICATION.md)，**不要在別處另寫一份**：

- 目錄層級與章的職責界線 → §1、§2
- 單篇報告骨架 → §3
- 標題規範 H-1～H-6 → §4
- 檔名規範 N-1～N-5、圖檔字典、名詞統一表 → §5

## 環境事實

這些是實測結果，照做可省下重複踩坑的時間。

| 項目 | 事實 |
| --- | --- |
| 作業系統 | Windows，預設 shell 是 **Windows PowerShell 5.1**（非 pwsh 7） |
| `.ps1` 編碼 | 含中文的腳本**必須存成 UTF-8 with BOM**，否則 PS 5.1 以 ANSI 解讀導致語法錯誤 |
| `.md` 編碼 | UTF-8 **不含** BOM |
| .NET API | PS 5.1 走 .NET Framework，**沒有** `[System.IO.Path]::GetRelativePath` |
| percent-decode | 一律用 `[System.Uri]::UnescapeDataString()`。本機 Git Bash 的 `printf '%b'` **不支援 `\xHH`**，用 bash 解碼會靜默失敗、把全部連結誤判為斷鏈 |
| 中文路徑 | repo 已設 `core.quotepath false`。若 `git status` 顯示為 `\350\263...` 八進位跳脫，重設此項 |
| 換行 | 由 [`.gitattributes`](.gitattributes) 釘住：`.md` 工作區與庫內都是 LF，`.ps1` 工作區 CRLF、庫內 LF。本機雖有 `core.autocrlf=true`，但那是**系統層級**設定（`git config --system`），換台機器不一定有——不要依賴它 |
| Python | **不可用**（`python3` 只是 Microsoft Store 的 stub）。腳本一律用 PowerShell |

## 連結格式

報告間的相對連結是 **percent-encoded 的中文路徑**，例如：

```
[架構設計](RAG%E5%90%91%E9%87%8F%E8%B3%87%E6%96%99%E5%BA%AB/%E6%9E%B6%E6%A7%8B%E8%A8%AD%E8%A8%88.md)
```

- 改檔名後**必須同步改寫所有指向它的連結**，這是本 repo 最常見的破壞方式：本機看起來正常，推上 GitHub 才發現 404
- 一律相對路徑，不得寫絕對網址
- 空格編為 `%20`；括號建議編為 `%28` `%29`
