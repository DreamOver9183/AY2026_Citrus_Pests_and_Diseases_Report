# 植物病蟲害辨識 (115 資工四A)

柑橘病蟲害辨識專題的完整研究報告。系統採**端側離線優先**設計，三大模組如下：

- **影像辨識**：以 YOLO26 系列（含 Nano / Nano-P2 / Large）訓練柑橘葉部病蟲害偵測模型，量化為 TFLite FP16 後部署至手機。
- **RAG 向量資料庫**：SQLite + FTS5 + sqlite-vec 建構本地向量檢索，搭配 LLaMA-Factory 微調的 Qwen2.5-0.5B GGUF 小語言模型，離線產生防治建議。
- **行動端應用程式**：以 Flutter 開發 Android / iOS App，整合上述兩個模組。

## 從哪裡開始讀

| 你是 | 從這裡進去 |
| --- | --- |
| 指導教授、評審、農業研究者 | [研究報告總覽](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/README.md) — 七章的章旨與全部子篇 |
| 行動端／邊緣端工程師 | [RAG 架構設計](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/RAG%E5%90%91%E9%87%8F%E8%B3%87%E6%96%99%E5%BA%AB/%E6%9E%B6%E6%A7%8B%E8%A8%AD%E8%A8%88.md)、[Flutter 實作與模組整合](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/%E8%A1%8C%E5%8B%95%E7%AB%AF%E6%87%89%E7%94%A8%E7%A8%8B%E5%BC%8F%E9%96%8B%E7%99%BC/Flutter%E5%AF%A6%E4%BD%9C%E8%88%87%E6%A8%A1%E7%B5%84%E6%95%B4%E5%90%88.md) |
| 想直接看數據 | [系統測試與評估](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/README.md#%E7%B3%BB%E7%B5%B1%E6%B8%AC%E8%A9%A6%E8%88%87%E8%A9%95%E4%BC%B0) — 各模型 TFLite benchmark 與行動端實測 |
| AI agent 或維護者 | [`AGENTS.md`](AGENTS.md) 操作規則 ｜ [`.agent/SPECIFICATION.md`](.agent/SPECIFICATION.md) 報告撰寫規範 |

## 章節

| 章節 | 內容 |
| --- | --- |
| [行動端應用程式開發](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/README.md#%E8%A1%8C%E5%8B%95%E7%AB%AF%E6%87%89%E7%94%A8%E7%A8%8B%E5%BC%8F%E9%96%8B%E7%99%BC) | Flutter 專案結構、需求分析、UML |
| [病蟲害辨識模型](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/README.md#%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%E6%A8%A1%E5%9E%8B) | 模型訓練數據報告、YOLO26 各版本比較、v8/v5 比較、開發週報 |
| [RAG向量資料庫](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/README.md#rag%E5%90%91%E9%87%8F%E8%B3%87%E6%96%99%E5%BA%AB) | 架構設計、提示詞、手機效能測試、SLM 微調與訓練資料集 |
| [系統測試與評估](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/README.md#%E7%B3%BB%E7%B5%B1%E6%B8%AC%E8%A9%A6%E8%88%87%E8%A9%95%E4%BC%B0) | 各模型 TFLite FP16 benchmark 報告 |
| [效能指標評估](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/README.md#%E6%95%88%E8%83%BD%E6%8C%87%E6%A8%99%E8%A9%95%E4%BC%B0) | 影像辨識與 RAG/SLM 模組的效能指標定義 |
| [資料集分析](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/README.md#%E8%B3%87%E6%96%99%E9%9B%86%E5%88%86%E6%9E%90) | 資料集統計報告 |
| [參考文獻與參考資料](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/README.md#%E5%8F%83%E8%80%83%E6%96%87%E7%8D%BB%E8%88%87%E5%8F%83%E8%80%83%E8%B3%87%E6%96%99) | 論文文獻、開源專案參考 |

## 資料說明

- 本報告內容自 Notion 匯出後整理，原始匯出檔名中的 Notion ID 已移除，檔案間相對連結已一併改寫。
- 參考文獻中的**第三方論文 PDF 未納入版本控制**，改以官方 / arXiv 連結呈現。

## 異動紀錄

本 repo 由團隊成員與 AI agent 共同維護。**任何人或 agent 的每一次 commit，都必須在 [`CHANGELOG.md`](CHANGELOG.md) 用固定格式新增一筆紀錄**（日期時間、異動人/Agent、範圍、摘要、影響檔案、對應 commit），寫在檔案最上方，不覆寫舊條目。格式細節與範本見 [`CHANGELOG.md`](CHANGELOG.md) 本身；AI agent 的執行流程見 [`AGENTS.md`](AGENTS.md) 的「異動紀錄」一節與 [`.agent/skills/commit-and-push/SKILL.md`](.agent/skills/commit-and-push/SKILL.md)。

紀錄累積超過 50 筆或 50KB 時，主檔只保留最近 15 筆，較舊的整段搬到 [`.agent/changelog_archive/`](.agent/changelog_archive/README.md)——歷史全部留著，只是不再佔用主檔。

## 給 AI agent 與維護者

報告撰寫規範（目錄層級、章的職責界線、報告骨架、標題 H-1～H-6、檔名 N-1～N-5、圖檔字典、名詞統一表）已移到 [`.agent/SPECIFICATION.md`](.agent/SPECIFICATION.md)，不再放在本檔。動手前請先讀 [`AGENTS.md`](AGENTS.md)：那裡有紅線、收工關卡與任務路由。
