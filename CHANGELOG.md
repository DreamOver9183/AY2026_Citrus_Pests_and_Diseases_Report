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

## 2026-08-27 — Claude Code

- **範圍**：規則文件
- **摘要**：建立本異動 log 機制，規定之後每個 commit 都必須在此新增一筆固定格式的紀錄；同步更新 `AGENTS.md`、`commit-and-push` skill 執行流程，並在 `README.md` 補一節讓團隊成員也看得到這條規則
- **影響檔案**：新增 `CHANGELOG.md`；修改 `AGENTS.md`、`.agent/skills/commit-and-push/SKILL.md`、`README.md`
- **commit**：`0773ef9`
