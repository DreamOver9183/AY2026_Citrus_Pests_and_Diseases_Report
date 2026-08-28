# 植物病蟲害辨識 (115 資工四A)

柑橘病蟲害辨識專題的完整研究報告。系統採**端側離線優先**設計，三大模組如下：

- **影像辨識**：以 YOLO26 系列（含 Nano / Nano-P2 / Large）訓練柑橘葉部病蟲害偵測模型，量化為 TFLite FP16 後部署至手機。
- **RAG 向量資料庫**：SQLite + FTS5 + sqlite-vec 建構本地向量檢索，搭配 LLaMA-Factory 微調的 Qwen2.5-0.5B GGUF 小語言模型，離線產生防治建議。
- **行動端應用程式**：以 Flutter 開發 Android / iOS App，整合上述兩個模組。

## 目錄

| 章節 | 內容 |
| --- | --- |
| [行動端應用程式開發](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/%E8%A1%8C%E5%8B%95%E7%AB%AF%E6%87%89%E7%94%A8%E7%A8%8B%E5%BC%8F%E9%96%8B%E7%99%BC.md) | Flutter 專案結構、需求分析、UML |
| [病蟲害辨識模型](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%E6%A8%A1%E5%9E%8B.md) | 模型訓練數據報告、YOLO26 各版本比較、v8/v5 比較、開發週報 |
| [RAG向量資料庫](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/RAG%E5%90%91%E9%87%8F%E8%B3%87%E6%96%99%E5%BA%AB.md) | 架構設計、提示詞、手機效能測試、SLM 微調與訓練資料集 |
| [系統測試與評估](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/%E7%B3%BB%E7%B5%B1%E6%B8%AC%E8%A9%A6%E8%88%87%E8%A9%95%E4%BC%B0.md) | 各模型 TFLite FP16 benchmark 報告 |
| [效能指標評估](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/%E6%95%88%E8%83%BD%E6%8C%87%E6%A8%99%E8%A9%95%E4%BC%B0.md) | 影像辨識與 RAG/SLM 模組的效能指標定義 |
| [資料集分析](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/%E8%B3%87%E6%96%99%E9%9B%86%E5%88%86%E6%9E%90.md) | 資料集統計報告 |
| [參考文獻與參考資料](%E6%A4%8D%E7%89%A9%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%20%28115%E8%B3%87%E5%B7%A5%E5%9B%9BA%29/%E5%8F%83%E8%80%83%E6%96%87%E7%8D%BB%E8%88%87%E5%8F%83%E8%80%83%E8%B3%87%E6%96%99.md) | 論文文獻、開源專案參考 |

### 資料說明

- 本報告內容自 Notion 匯出後整理，原始匯出檔名中的 Notion ID 已移除，檔案間相對連結已一併改寫。
- 參考文獻中的**第三方論文 PDF 未納入版本控制**，改以官方 / arXiv 連結呈現。

### 異動紀錄

本 repo 由團隊成員與 AI agent 共同維護。**任何人或 agent 的每一次 commit，都必須在 [`CHANGELOG.md`](CHANGELOG.md) 用固定格式新增一筆紀錄**（日期時間、異動人/Agent、範圍、摘要、影響檔案、對應 commit），寫在檔案最上方，不覆寫舊條目。格式細節與範本見 [`CHANGELOG.md`](CHANGELOG.md) 本身；AI agent 的執行流程見 [`AGENTS.md`](AGENTS.md) 的「異動紀錄」一節與 [`.agent/skills/commit-and-push/SKILL.md`](.agent/skills/commit-and-push/SKILL.md)。

---

# 報告撰寫規範

> **本節只定義規範。**
> 制定日：2026-08-27，依據當日全庫盤點（25 篇報告、314 個標題、48 張圖）。
> 2026-08-27 完成全庫套用：檔名、章節職責重疊、標題與骨架規範三批工作皆已收尾，`.agent/baseline.json` 13 項結構指標全數為 0；§6 說明如何取得即時的落差清單以確認現況。
> 新增或改寫任何報告時，以本節為準。

**AI agent 請先讀 [`AGENTS.md`](AGENTS.md)**，那裡有紅線、驗證關卡與任務路由；本節是它引用的規範本體。規範是否被遵守由 [`.agent/scripts/`](.agent/scripts) 下的腳本自動檢查，不靠人工複查。

## 1. 目錄層級

全庫固定**三層**，不設第四層。

| 層 | 路徑樣式 | 角色 | 內容限制 |
| --- | --- | --- | --- |
| L0 | `README.md` | 專案唯一入口 | 專案簡介、章索引、本規範。不放研究內容 |
| L1 | `植物病蟲害辨識 (115資工四A)/<章名>.md` | 章索引 | **只做導覽**：3 行以內的章旨 + 子篇清單 |
| L2 | `植物病蟲害辨識 (115資工四A)/<章名>/<篇名>.md` | 報告本體 | 一篇一主題，是唯一放正文的地方 |
| 資產 | `植物病蟲害辨識 (115資工四A)/<章名>/<篇名>/` | 圖表資料夾 | 與該篇同名，只放該篇引用的圖 |

**規則**

1. L1 章索引不得寫正文。某章即使目前只有一篇內容，仍應拆成「章索引 + 一篇 L2」。
2. 圖片一律放在與報告同名的資產資料夾，不共用、不跨篇引用。多篇需要同一張圖時，改為在文中連結到原報告章節。
3. md 之間互相引用一律使用**相對路徑**，不得寫絕對網址。

## 2. 章的職責界線

每章只負責一個問題。此表用來判斷「一篇新報告該放哪一章」，也用來裁決重疊內容的歸屬。

| 章 | 只放 | 明確不放 |
| --- | --- | --- |
| **資料集分析** | 資料集本身：規模、類別分佈、train/valid/test 劃分、增廣、標註品質 | 任何模型訓練結果 |
| **病蟲害辨識模型** | 偵測模型的訓練與版本比較：超參數、收斂曲線、mAP / PR / 混淆矩陣 | 資料集統計（改引用〈資料集分析〉）、實機推論速度 |
| **RAG向量資料庫** | 檢索與 SLM 的**設計與製作**：架構、提示詞、微調流程、知識訓練集 | 手機實測數據 |
| **行動端應用程式開發** | App 需求、UML、Flutter 實作與整合 | 模型與 RAG 的內部設計 |
| **系統測試與評估** | **所有實機實測數據**：TFLite benchmark、行動端 RAG/LLM 實測、跨裝置對比 | 指標的定義與算式 |
| **效能指標評估** | **只放定義**：指標名稱、公式、單位、評測方法（RAGAS 等） | 任何實測數值與實驗記錄 |
| **參考文獻與參考資料** | 外部論文、開源專案 | 專題自身的產出 |

判斷口訣：**「怎麼算」進〈效能指標評估〉，「算出來多少」進〈系統測試與評估〉，「怎麼做出來的」進各建置章。**

## 3. 單篇報告骨架

每篇 L2 報告依序包含以下段落，順序不得調換。

| # | 段落 | 必要性 | 內容 |
| --- | --- | --- | --- |
| 1 | `# <報告全名>` | 必要 | 全檔唯一的 H1 |
| 2 | 報告資訊區塊 | 必要 | 引用區塊（`>`），列出：報告日期、評測對象、資料來源（log 檔名 / commit）、撰寫人 |
| 3 | `## 目錄` | 超過 400 行時必要 | 純錨點連結 |
| 4 | `## 1. 摘要` | 必要 | 3–5 條結論 + 一張核心數據表 |
| 5 | `## 2. 方法與環境` | 實驗類必要 | 硬體、超參數、資料集版本、量化設定 |
| 6 | `## 3. 數據與分析` | 必要 | 先表後圖；每張圖需有圖號與一句解讀 |
| 7 | `## 4. 結論與限制` | 必要 | 須含「本報告未涵蓋」一小段 |

**設計／說明類報告**（如〈架構設計〉〈需求分析〉〈提示詞〉）免除第 5、6 段，第 1、2、4 段仍必要。

## 4. 標題規範

| 編號 | 規則 |
| --- | --- |
| H-1 | 一份檔案**只能有一個 H1**，且與檔名語意一致。不得保留匯出工具產生的頁標題 H1 |
| H-2 | 標題層級**不得跳級**（H1 → H2 → H3，不可 H1 → H3） |
| H-3 | 最深只到 **H4**。需要更細的層次改用清單或表格 |
| H-4 | 標題文字**不加粗**（不寫 `## **標題**`）、**不放 emoji** |
| H-5 | 章節編號統一為 `1.` / `1.1` / `1.1.1`。**不使用**「一、二、三」中文數字；同一層級編號不得重複 |
| H-6 | 表與圖使用**獨立於章節編號**的流水號：`表 3-1`、`圖 3-1`，並緊接一句說明 |

## 5. 檔名規範

### 5.1 通則

| 編號 | 規則 |
| --- | --- |
| N-1 | 檔名**不得含空格、括號、全形符號**。分隔字元：詞內用 `-`，欄位間用 `_` |
| N-2 | 中文檔名**只用於**章索引與設計／說明類文件 |
| N-3 | 技術產出類（訓練、測試、統計）一律**英文 lower_snake_case** |
| N-4 | **禁止用流水號結尾**區分內容（`results 1.png`、`報告 2.md`）。差異必須寫進檔名 |
| N-5 | 日期一律 `YYYYMMDD`（8 位、含年份），且置於檔名**最前** |

### 5.2 報告檔名樣式

| 類型 | 樣式 | 範例 |
| --- | --- | --- |
| 章索引 | `<章名>.md` | `病蟲害辨識模型.md` |
| 設計／說明 | `<主題>.md`（中文 2–8 字） | `架構設計.md`、`需求分析.md` |
| 訓練報告 | `<日期>_<模型代號>_training_report.md` | `20260729_yolo26n_p2_training_report.md` |
| 基準測試 | `<模型代號>_<精度>_benchmark.md` | `yolo26n_p2_fp16_benchmark.md` |
| 版本比較 | `<代號A>_vs_<代號B>_comparison.md` | `yolo26n_p2_v2_vs_v3_comparison.md` |
| 資料集統計 | `<資料集代號>_dataset_stats.md` | `yolo26_v2_dataset_stats.md` |
| 週期報告 | `<日期>_weekly_report.md` | `20260729_weekly_report.md` |

### 5.3 圖檔命名

樣式：`<對象>_<圖表類型>[_<條件>].<副檔名>`

圖表類型只能用下表字典中的詞：

**單一模型的訓練輸出**

| 字典值 | 圖表 | 字典值 | 圖表 |
| --- | --- | --- | --- |
| `results` | 訓練總覽曲線 | `confusion_matrix` | 混淆矩陣 |
| `pr_curve` | Precision–Recall 曲線 | `confusion_matrix_norm` | 正規化混淆矩陣 |
| `f1_curve` | F1 曲線 | `labels` | 標籤分佈 |
| `p_curve` | Precision 曲線 | | |
| `r_curve` | Recall 曲線 | | |

**跨模型／跨版本對比**

| 字典值 | 圖表 |
| --- | --- |
| `loss_comparison` | 損失對比 |
| `map_comparison` | mAP 對比 |
| `pr_comparison` | PR 曲線對比 |
| `metrics_curve` | 多版本驗證指標疊圖 |
| `ap_by_class` | 逐類別 AP 對比 |

**資料集圖表**

| 字典值 | 圖表 |
| --- | --- |
| `architecture` | 架構／流程圖 |
| `split_distribution` | train / valid / test 劃分分佈 |
| `class_distribution` | 類別占比分佈 |
| `bbox_count` | 標註框實際計數 |

範例：`yolo26n_p2_pr_curve.png`、`ssd_mnv3_large_confusion_matrix.png`、`dataset_class_distribution_train.png`、`yolo26n_p2_v5_vs_v8_metrics_curve.jpg`

### 5.4 名詞統一表

同一個對象在全庫必須寫成同一種形式。檔名用「代號」欄，正文用「正式名稱」欄。

| 代號（檔名用） | 正式名稱（正文用） | 現況出現過的寫法 |
| --- | --- | --- |
| `yolo26n_p2` | YOLO26-nano-P2 | `YOLO26_Nano_P2`、`YOLO26-nano-p2`、`yolo26-nano-p2`、`YOLO26n P2`、`YOLO26n-P2`、`YOLO26 Nano P2` |
| `yolo26n` | YOLO26-nano | `YOLO26-nano`、`yolo26-nano`、`YOLO26n`、`YOLO26 Nano` |
| `yolo26l` | YOLO26-large | `YOLO26-large` |
| `ssd_mnv3_large` | SSD-MobileNetV3-large | `ssd_mobilenetv3_large`、`SSD-MobileNetV3-large` |
| `ssd_mnv3_small` | SSD-MobileNetV3-small | `ssd_mobilenetv3_small`、`SSD-MobileNetV3-small` |
| `qwen25_05b` | Qwen2.5-0.5B | `Qwen2.5-0.5B`、`Qwen 2.5 0.5B`、`Qwen2.5 0.5B`、`qwen2.5-0.5b` |

## 6. 現況落差盤點

現有報告尚未套用本規範。**具體數字不寫在這裡**——寫死的數字改一次就過期，改用腳本即時產生：

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/audit-structure.ps1 -Verbose
```

基準線存於 [`.agent/baseline.json`](.agent/baseline.json)。腳本採**棘輪機制**：既有問題不必一次修完，但任何一項指標上升就 fail，確保不會愈改愈亂。

### 6.1 指標與規則對照

| 指標 | 對應規則 |
| --- | --- |
| `dup_h1_files` | H-1 一檔多個 H1（匯出頁標題與內文標題並存） |
| `heading_level_jumps` | H-2 標題跳級 |
| `headings_deeper_than_h4` | H-3 超過 H4 |
| `bold_headings` / `emoji_headings` | H-4 標題加粗或含 emoji |
| `cn_numbered_headings` | H-5 使用「一、二、三」編號 |
| `duplicate_headings` | H-5 同檔同層標題重複 |
| `files_without_summary` | 骨架 #4 缺摘要 |
| `filename_with_space` / `filename_with_paren` | N-1 檔名含空格或括號 |
| `image_serial_suffix` | N-4 圖檔以流水號結尾 |
| `image_placeholder_name` / `image_uuid_name` | §5.3 匯出工具產生的無語意檔名 |

### 6.2 章的職責重疊（已完成）

| 原位置 | 問題 | 依 §2 應歸屬 | 現況 |
| --- | --- | --- | --- |
| `RAG向量資料庫/效能測試 - 手機.md` | 是行動端實機實測數據，卻放在建置章 | 系統測試與評估 | **已搬移**為 `系統測試與評估/20260729_mobile_rag_benchmark.md` |
| `效能指標評估.md` 的「RAGAs 評估實驗記錄」 | 定義章混入實測記錄 | 系統測試與評估 | **已搬移**為 `系統測試與評估/citrus_rag_ragas_evaluation.md` |
| `病蟲害辨識模型/20260729_yolo26n_p2_training_report.md` §3「資料集概況」 | 資料集統計寫在訓練報告內，經查實為 `Datasets_YOLO26_v5`（非既有 v2）版本 | 改為引用〈資料集分析〉 | **已拆分**為 `資料集分析/yolo26_v5_dataset_stats.md`，訓練報告 §3 改為引用連結 |
| `效能指標評估.md`、`參考文獻與參考資料.md` | 無子頁，正文直接寫在 L1 章索引 | 拆為章索引 + L2 報告 | **已拆分**：效能指標評估 → `效能指標評估/指標定義與評測方法.md`；參考文獻與參考資料 → `學術文獻回顧.md` + `開源專案參考.md` |

### 6.3 標題與骨架規範（已完成）

`dup_h1_files`、`heading_level_jumps`、`headings_deeper_than_h4`、`bold_headings`、`emoji_headings`、`cn_numbered_headings`、`duplicate_headings`、`files_without_summary` 八項指標皆已收斂為 0：移除重複 H1 與標題跳級、去除標題加粗與 emoji、中文數字編號改阿拉伯數字、消除同層重複標題、為所有缺摘要的檔案補上「摘要」段落。

### 6.4 檔名（已完成）

13 篇報告與 4 個資產資料夾已依 §5.2 更名，48 張圖已依 §5.3 更名。`filename_with_space`、`filename_with_paren`、`image_serial_suffix`、`image_placeholder_name`、`image_uuid_name` 五項指標皆為 0。

圖檔語意逐張由引用點的章節標題或圖說推得。最典型的一組 —— `Image/20260714_all_models_training_metrics/` 裡這四張圖原本分屬四個不同模型卻檔名相同，只靠尾碼區分：

| 原檔名 | 實際內容 | 現檔名 |
| --- | --- | --- |
| `results.png` | YOLO26-large | `yolo26l_results.png` |
| `results 1.png` | YOLO26-nano | `yolo26n_results.png` |
| `results 2.png` | YOLO26-nano+P2 | `yolo26n_p2_results.png` |
| `results 3.png` | YOLO26-nano-p2-w8a32 | `yolo26n_p2_w8a32_results.png` |

這也是 N-4 禁止流水號的理由：機械地改成 `results_1.png` 會讓規則通過而缺陷留存，`apply-renames.ps1` 會直接擋下這種目標檔名。

## 7. 新增報告檢查清單

提交前逐項確認：

- [ ] 依 §2 職責界線，確認放對章
- [ ] 檔名符合 5.1 通則與 5.2 樣式，模型代號取自 5.4
- [ ] 只有一個 H1，且與檔名語意一致
- [ ] 標題無跳級、最深 H4、未加粗、無 emoji
- [ ] 章節編號為 `1.` / `1.1`，同層無重號
- [ ] 具備報告資訊區塊（日期／對象／資料來源／撰寫人）
- [ ] 具備摘要與「結論與限制」
- [ ] 圖片放在章節 `Image/` 底下與報告同名的資產資料夾，檔名取自 5.3 字典，無流水號
- [ ] 每張圖有圖號與一句解讀
- [ ] 超過 400 行者附目錄
- [ ] md 之間以相對路徑互連，連結可點開
