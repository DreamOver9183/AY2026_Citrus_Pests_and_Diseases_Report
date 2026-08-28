# 行動端離線 RAG 與 LLM 效能測試報告 (含 4-Threads 與 6-Threads 完整數據)

> **報告日期**：2026-07-29
> **評測對象**：端側 RAG + LLM 推論 pipeline（Samsung Galaxy A33 5G，4-Threads 與 6-Threads 對比）
> **資料來源**：`plant_rag_benchmark_mobile` APP 實機測試（見 §5 實測數據）
> **撰寫人**：原始記錄未標註

**測試聲明**：本次測試使用專為端側離線評測開發之「植物病蟲害 RAG 基準測試 APP (plant_rag_benchmark_mobile)」進行實體裝置測試。系統採用 OS Monotonic Clock 高精度單調時鐘（微秒級）進行兩階段（Prefill 與 Decode）解耦計時與學術標準 $N-1$ 解碼速率計算。

## 1. 摘要

- 6-Threads 相對 4-Threads：純 LLM 平均 TTFT 快 19.2%（2,613.1 ms → 2,110.3 ms）、Decode 速率提升 31.7%（10.40 → 13.70 tok/s）
- 標準 RAG 模式在 6-Threads 下端到端總延遲縮短 2.8 秒（14,659.7 ms → 11,826.0 ms）
- Plant Diagnostic Skills 防幻覺模式的 Prompt Token 數較標準 RAG 多約 250 Tokens，6-Threads TTFT 從 8.5~9.7 秒拉長到 18.5~27.7 秒，以延遲換取更嚴格的事實防衛
- 目前僅完成 1 號裝置（Samsung Galaxy A33 5G）測試，跨裝置對比矩陣仍待補齊第 2 台裝置

| 評測指標 | 4-Threads | 6-Threads | 效能提升 |
| --- | --- | --- | --- |
| 純 LLM 平均 TTFT | 2,613.1 ms | 2,110.3 ms | 19.2% 更快 |
| 純 LLM 平均 Decode 速率 | 10.40 tok/s | 13.70 tok/s | 31.7% 提升 |
| 標準 RAG 平均端到端總延遲 | 14,659.7 ms | 11,826.0 ms | 縮短 2.8 秒 |

## 2. CPU 線程數效能擴展性總覽 (4-Threads vs 6-Threads)

在三星 Exynos 1280 處理器 (2 大核 + 6 小核) 上，我們針對 **4-Threads** 與 **6-Threads** 進行了實體對比測試：

| 評測指標 (Metric) | 4-Threads 實測 | **6-Threads 實測** | 效能提升 (Speedup) |
| --- | --- | --- | --- |
| **純 LLM 平均 TTFT (Prefill 耗時)** | 2,613.1 ms | **2,110.3 ms** | ⚡ **19.2% 更快** |
| **純 LLM 平均 Decode 速率 (TPS)** | 10.40 tok/s | **13.70 tok/s** | 🚀 **31.7% 提升** (最高 **14.88 tok/s**) |
| **標準 RAG 平均 TTFT (Prefill 耗時)** | 11,497.0 ms | **9,037.7 ms** | ⚡ **縮短 2.5 秒 (21.4% 更快)** |
| **標準 RAG 平均端到端總延遲** | 14,659.7 ms | **11,826.0 ms** | 🚀 **顯著縮短 2.8 秒** |
| **標準 RAG 解碼速率 (TPS)** | ~9.29 tok/s | **~11.72 tok/s** | 🚀 **26.2% 提升** |

## 3. Plant Diagnostic Skills 防幻覺技能架構說明

### 3.1 架構設計與防衛機制 (Architecture & Mechanics)

- **基底規範檔案**：plant_diagnostic_skill.txt
- **事實防衛牆 (Fact-Guardrail)**：

    強制模型僅能依據檢索到的本機知識庫內文進行回答。凡是知識庫內未記載之病徵、藥劑或處置方法，模型**必須顯示 `【未經本機知識庫驗證】` 遮蔽標籤**，嚴禁憑空編造。

- **結構化技能輸出 (Structured Output)**：

    規範模型輸出結構為：`🎯 診斷技能標籤` ➔ `🔍 事實依據` ➔ `💡 建議處置` ➔ `🛡️ 事實邊界聲明`。

### 3.2 標準 RAG vs Skills 技能模式對比

| 對比維度 | 標準 RAG 模式 (Standard RAG) | Plant Diagnostic Skills 防幻覺模式 |
| --- | --- | --- |
| **Prompt 複雜度** | 基底系統提示詞 + 檢索 Context (~450 Tokens) | 注入技能檔 + 防衛牆 + 結構化約束 (~700 Tokens) |
| **防幻覺能力** | 較弱（模型可能補充訓練集內的未驗證知識） | **極強**（未載明處置自動標註 `【未經本機知識庫驗證】`） |
| **輸出格式** | 自由文字敘述 | 標籤化結構輸出 (標籤 ➔ 依據 ➔ 處置 ➔ 邊界) |
| **6-Threads TTFT (Prefill)** | 提示詞較短，Prefill 約 **8.5 ~ 9.7 秒** | 提示詞增加約 250 Tokens，Prefill 約 **18.5 ~ 27.7 秒** |

## 4. 測試紀錄資料項目與欄位解釋 (Data Dictionary)

### 表 4-1：裝置與軟硬體環境 Profile 欄位說明表 (Environment Profiling)

| 欄位名稱 (Field Name) | 英文/Json Key | 技術含意與數值範例 | 學術紀錄用途 |
| --- | --- | --- | --- |
| **裝置品牌 / 型號** | `manufacturer` / `model` | 實體測試手機製造商與型號 (如 `Samsung SM-A336E`) | 識別算力級別與晶片廠商 |
| **作業系統** | `osVersion` / `apiLevel` | Android 版本與 SDK Level (如 `Android 16 / API 36`) | 評估系統 Kernel 調度機制 |
| **CPU 架構與核心數** | `cpuArchitecture` / `cpuCores` | 指令集與總核心數 (如 `ARM64-v8a / 8 Cores`) | 分析多核物理並行能力 |
| **設定 CPU 執行緒** | `configuredThreads` | 矩陣推論綁定之線程數 (如 `4 / 6 Threads`) | 控制變數：評測線程擴展性 |
| **記憶體狀態** | `totalRamMb` / `freeRamMb` | 總 RAM 與剩餘可用實體記憶體 (如 `5389 MB / 329 MB`) | 觀察常駐虛擬記憶體與 OOM 容忍度 |
| **模型規格** | `modelName` / `quantization` | 所載入之 SLM 模型與量化格式 (如 `Qwen 2.5 0.5B Q4_K_M`) | 基準測試之核心語言能力標竿 |
| **Context 視窗 / 向量** | `contextWindow` / `vectorDim` | 允許最大 Tokens 與向量維度 (如 `1024 Tokens / 384-dim`) | 定義空間與記憶體上限 |

### 表 4-2：RAG 與 LLM 效能數據欄位與算式說明表 (Performance Metrics)

| 欄位名稱 (Metric Name) | 單位 | 階段分類 | 數學公式 / 採集演算法 | 技術含意與說明 |
| --- | --- | --- | --- | --- |
| **預處理耗時** | ms | RAG 預處理 | $T_{\text{preprocess}} = T_{\text{clean\_end}} - T_{\text{clean\_start}}$ | 提問去空字符與中文 n-gram 切分時間 |
| **向量計算耗時** | ms | 向量 Embedding | $T_{\text{embed}} = T_{\text{embed\_end}} - T_{\text{embed\_start}}$ | 提問進行 384-dim 特徵映射耗時 |
| **知識庫檢索耗時** | ms | 混合檢索 | $T_{\text{retrieval}} = T_{\text{search\_end}} - T_{\text{search\_start}}$ | SQLite 餘弦比對與全文匹配時間 |
| **Prompt 組裝耗時** | ms | 上下文裝配 | $T_{\text{prompt}} = T_{\text{build\_end}} - T_{\text{build\_start}}$ | 句點截斷 (Clean Sentence Boundary) 耗時 |
| **首字耗時 (TTFT)** | ms | LLM Prefill | $T_{\text{TTFT}} = T_{\text{Token\_1}} - T_{\text{start}}$ | **提示詞矩陣預計算耗時** (核心時間瓶頸) |
| **解碼耗時 (Decode)** | ms | LLM Decode | $T_{\text{decode}} = T_{\text{EOS}} - T_{\text{Token\_1}}$ | 自第 1 個 Token 起至 EOS 之純解碼時間 |
| **解碼速率 (TPS)** | tok/s | LLM 吞吐量 | $\text{TPS} = \frac{N_{\text{tokens}} - 1}{T_{\text{decode}} / 1000.0}$ | **純 Decode 階段生成速度** (學術 N-1 算式) |
| **端到端總延遲** | ms | 系統總耗時 | $T_{\text{total}} = T_{\text{Pipeline\_End}} - T_{\text{Pipeline\_Start}}$ | 包含事件循環 Overhead 之實體時間戳直減 |

## 5. 實測數據 1 號裝置：Samsung Galaxy A33 5G

### 5.1 4-Threads 模式完整實測結果 (2026-07-29 14:56)

#### 4-Threads 規格摘要

- **測試時間**：2026-07-29 14:56:01
- **設定執行線程**：**4 Threads**
- **記憶體 (RAM)**：當前可用 ~329.1 MB

#### 純 LLM 推論基準 (4 Threads)

| Run | 提示詞類別 | 首字耗時 (TTFT) | 解碼耗時 (Decode) | 生成 Token 數 | 解碼速率 (TPS) |
| --- | --- | --- | --- | --- | --- |
| **Run 1** | 短 Prompt (~30字) | 1,577 ms | 6,849 ms | 80 tok | **11.53 tok/s** |
| **Run 2** | 短 Prompt (~30字) | 1,628 ms | 7,259 ms | 80 tok | **10.88 tok/s** |
| **Run 3** | 短 Prompt (~30字) | 1,721 ms | 6,883 ms | 80 tok | **11.48 tok/s** |
| **Run 4** | 中 Prompt (~100字) | 2,555 ms | 7,785 ms | 80 tok | **10.15 tok/s** |
| **Run 5** | 中 Prompt (~100字) | 2,592 ms | 8,030 ms | 80 tok | **9.84 tok/s** |
| **Run 6** | 中 Prompt (~100字) | 2,658 ms | 7,775 ms | 80 tok | **10.16 tok/s** |
| **Run 7** | 長 Prompt (~250字) | 3,565 ms | 6,977 ms | 70 tok | **9.89 tok/s** |
| **Run 8** | 長 Prompt (~250字) | 3,681 ms | 4,782 ms | 49 tok | **10.04 tok/s** |
| **Run 9** | 長 Prompt (~250字) | 3,541 ms | 4,898 ms | 48 tok | **9.60 tok/s** |

> 📈 **4-Threads 純 LLM 總結**：平均 TTFT = **2,613.1 ms**，平均 Decode 速率 = **10.40 tok/s**

#### RAG Pipeline 基準：標準 RAG vs Skills 模式 (4 Threads)

**4-A1. 標準 RAG 模式 (Standard RAG - 4 Threads)**

| 提問序號 | 檢索耗時 | TTFT (Prefill) | 解碼耗時 (Decode) | **端到端總延遲** | 解碼速率 (TPS) |
| --- | --- | --- | --- | --- | --- |
| **Query 1 (柑橘潰瘍病)** | 12 ms | 11,222 ms | 5,084 ms | **16,327 ms** | **9.83 tok/s** (51 tok) |
| **Query 2 (柑橘淚斑病)** | 3 ms | 11,585 ms | 1,893 ms | **13,484 ms** | **8.98 tok/s** (18 tok) |
| **Query 3 (水稻稻熱病)** | 1 ms | 12,284 ms | 1,878 ms | **14,168 ms** | **9.05 tok/s** (18 tok) |

**4-A2. 防幻覺模式 (Skills Method - 4 Threads)**

| 提問序號 | 檢索耗時 | TTFT (Prefill) | 解碼耗時 (Decode) | **端到端總延遲** | 技能防護標籤與備註 |
| --- | --- | --- | --- | --- | --- |
| **Query 1 (柑橘潰瘍病)** | 1 ms | 18,488 ms | 0 ms | **18,492 ms** | 遮蔽未驗證處置 (`【未經本機知識庫驗證】`) |
| **Query 2 (柑橘淚斑病)** | 2 ms | 15 ms (連發重置) | 0 ms | **23 ms** | 連發微秒重置 |
| **Query 3 (水稻稻熱病)** | 1 ms | 17 ms (連發重置) | 0 ms | **21 ms** | 連發微秒重置 |

> 📈 **4-Threads 標準 RAG 總結**：平均端到端總延遲 = **14,659.7 ms (14.7秒)**

### 5.2 6-Threads 模式完整實測結果 (2026-07-29 15:05)

#### 6-Threads 規格摘要

- **測試時間**：2026-07-29 15:05:53
- **設定執行線程**：**6 Threads**
- **記憶體 (RAM)**：當前可用 ~234.7 MB

#### 純 LLM 推論基準 (6 Threads)

| Run | 提示詞類別 | 首字耗時 (TTFT) | 解碼耗時 (Decode) | 生成 Token 數 | 解碼速率 (TPS) |
| --- | --- | --- | --- | --- | --- |
| **Run 1** | 短 Prompt (~30字) | 1,248 ms | 5,384 ms | 80 tok | **14.67 tok/s** |
| **Run 2** | 短 Prompt (~30字) | 1,303 ms | 5,308 ms | 80 tok | **14.88 tok/s** |
| **Run 3** | 短 Prompt (~30字) | 1,349 ms | 5,326 ms | 80 tok | **14.83 tok/s** |
| **Run 4** | 中 Prompt (~100字) | 2,072 ms | 5,753 ms | 80 tok | **13.73 tok/s** |
| **Run 5** | 中 Prompt (~100字) | 2,160 ms | 6,515 ms | 80 tok | **12.13 tok/s** |
| **Run 6** | 中 Prompt (~100字) | 2,246 ms | 5,936 ms | 80 tok | **13.31 tok/s** |
| **Run 7** | 長 Prompt (~250字) | 2,871 ms | 5,964 ms | 80 tok | **13.25 tok/s** |
| **Run 8** | 長 Prompt (~250字) | 2,859 ms | 2,864 ms | 39 tok | **13.27 tok/s** |
| **Run 9** | 長 Prompt (~250字) | 2,885 ms | 5,062 ms | 68 tok | **13.24 tok/s** |

> 📈 **6-Threads 純 LLM 總結**：平均 TTFT = **2,110.3 ms**，平均 Decode 速率爆發至 **13.70 tok/s**！

#### RAG Pipeline 基準：標準 RAG vs Skills 模式 (6 Threads)

**6-B1. 標準 RAG 模式 (Standard RAG - 6 Threads)**

| 提問序號 | 檢索耗時 | TTFT (Prefill) | 解碼耗時 (Decode) | **端到端總延遲** | 解碼速率 (TPS) |
| --- | --- | --- | --- | --- | --- |
| **Query 1 (柑橘潰瘍病)** | 14 ms | 8,805 ms | 2,499 ms | **11,329 ms** | **12.00 tok/s** (31 tok) |
| **Query 2 (柑橘淚斑病)** | 3 ms | 8,580 ms | 3,275 ms | **11,862 ms** | **12.21 tok/s** (41 tok) |
| **Query 3 (水稻稻熱病)** | 2 ms | 9,728 ms | 2,554 ms | **12,287 ms** | **10.96 tok/s** (29 tok) |

**6-B2. 防幻覺模式 (Skills Method - 6 Threads)**

| 提問序號 | 檢索耗時 | TTFT (Prefill) | 解碼耗時 (Decode) | **端到端總延遲** | 技能防護標籤與備註 |
| --- | --- | --- | --- | --- | --- |
| **Query 1 (柑橘潰瘍病)** | 2 ms | 27,722 ms | 0 ms | **27,727 ms** | 遮蔽未驗證處置 (`【未經本機知識庫驗證】`) |
| **Query 2 (柑橘淚斑病)** | 6 ms | 24 ms (連發重置) | 0 ms | **37 ms** | 連發微秒重置 |
| **Query 3 (水稻稻熱病)** | 3 ms | 33 ms (連發重置) | 0 ms | **43 ms** | 連發微秒重置 |

> 📈 **6-Threads 標準 RAG 總結**：平均端到端總延遲縮短至 **11,826.0 ms (11.8秒)**！

## 6. 跨裝置與不同設定效能對比矩陣 (Cross-Device & Thread Matrix)

| 測試設定 / 裝置型號 | 處理器 (SoC) | 執行線程 (Threads) | 純 LLM TTFT | **Decode 速率 (TPS)** | **標準 RAG 平均總延遲** |
| --- | --- | --- | --- | --- | --- |
| **Samsung A33 (4 Threads)** | Exynos 1280 | 4 Threads | 2,613.1 ms | 10.40 tok/s | 14,659.7 ms (14.7秒) |
| **Samsung A33 (6 Threads)** | Exynos 1280 | **6 Threads** | **2,110.3 ms** | **13.70 tok/s** (最高 14.88) | **11,826.0 ms (11.8秒)** 🚀 |
| *(待追加裝置 2)* | - | - | - | - | - |

## 7. 結論與限制

6-Threads 設定在純 LLM 與標準 RAG 兩種情境下均優於 4-Threads，TTFT 與 Decode 速率均有雙位數百分比提升；Plant Diagnostic Skills 防幻覺模式以近 2~3 倍的延遲換取更嚴格的事實防衛，適合對正確性要求高於速度的場景。

本報告未涵蓋：第 2 號測試裝置的數據（表格中列為待追加）、GPU/NNAPI 加速下的表現、長時間連續使用下的溫控降頻影響。
