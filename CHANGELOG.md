# CHANGELOG

本檔記錄這個共用 repo 的**每一次異動**——不論是團隊成員或 AI agent 做的。目的是讓任何人不必翻 `git log` 就能快速看懂「最近發生了什麼」。

## 規則

- **每個 commit 對應一筆 log**，寫在本檔**最上方**（新到舊）。不覆寫、不刪除舊條目。
- 寫入時機與流程見 [`.agent/skills/commit-and-push/SKILL.md`](.agent/skills/commit-and-push/SKILL.md)——log 是 commit 流程的必要步驟，不是事後補記。
- 固定欄位如下，缺一不可：

| 欄位 | 說明 |
| --- | --- |
| 日期時間 | `YYYY-MM-DD HH:mm`，本地時間 |
| 異動人/Agent | 人類寫真名或代稱；AI agent 寫工具名（如 `Claude Code`） |
| 範圍 | 固定分類詞之一：`檔名`／`內容`／`結構`／`連結修復`／`規則文件`／`其他` |
| 摘要 | 一到兩句話講做了什麼、為什麼；可直接沿用 commit message 第一段 |
| 影響檔案 | 相對路徑列點；檔案多時可寫「資料夾 + 檔數」 |
| commit | 對應的 git short hash |

條目範本：

```markdown
## 2026-08-27 14:30 — Claude Code

- **範圍**：檔名
- **摘要**：套用命名規範，重新命名 48 張圖、13 篇報告、4 個資產資料夾
- **影響檔案**：`病蟲害辨識模型/` 下 4 個資料夾共 48 張圖；13 篇報告檔名
- **commit**：`07cb204`
```

---

## 2026-08-27 15:50 — Claude Code

- **範圍**：結構
- **摘要**：依 README §6.2 處理三項章節職責重疊：(1) 將效能指標評估.md 內的「RAGAs 評估實驗記錄」搬到系統測試與評估／新增 citrus_rag_ragas_evaluation.md；(2) 訓練報告 §3「資料集概況」發現實為不同版本資料集（v5 非既有 v2），故新增 資料集分析/yolo26_v5_dataset_stats.md 收納並改為引用，同時搬移對應 5 張資料集圖檔、修掉 yolo26_v2_dataset_stats.md 與訓練報告本身的重複 H1；(3) 效能指標評估.md、參考文獻與參考資料.md 拆分為 L1 章索引 + L2 報告（參考文獻拆為學術文獻回顧、開源專案參考兩篇）
- **影響檔案**：新增 3 個 L2 報告 + 移動 5 張圖檔；修改 效能指標評估.md、系統測試與評估.md、資料集分析.md、參考文獻與參考資料.md、20260729_yolo26n_p2_training_report.md、yolo26_v2_dataset_stats.md；audit：dup_h1_files 11→9、heading_level_jumps 6→5、bold_headings 21→5、emoji_headings 31→25、duplicate_headings 4→3、files_without_summary 16→13，基準線已收緊
- **commit**：`dc86163`

---

## 2026-08-27 — Claude Code

- **範圍**：規則文件
- **摘要**：建立本異動 log 機制，規定之後每個 commit 都必須在此新增一筆固定格式的紀錄；同步更新 `AGENTS.md`、`commit-and-push` skill 執行流程，並在 `README.md` 補一節讓團隊成員也看得到這條規則
- **影響檔案**：新增 `CHANGELOG.md`；修改 `AGENTS.md`、`.agent/skills/commit-and-push/SKILL.md`、`README.md`
- **commit**：`0773ef9`
