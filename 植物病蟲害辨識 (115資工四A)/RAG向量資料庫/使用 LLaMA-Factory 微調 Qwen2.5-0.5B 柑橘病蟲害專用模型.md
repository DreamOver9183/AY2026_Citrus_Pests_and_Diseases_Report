# 使用 LLaMA-Factory 微調 Qwen2.5-0.5B 柑橘病蟲害專用模型

> **目標：** 利用低秩適應（LoRA）技術微調 Qwen2.5-0.5B-Instruct，並注入領域防護 Guardrails，最後導出為可供 `llama.cpp` 離線運行的 Q4_K_M GGUF 檔案。
> 

## 操作說明

## 🛠️ 一、 環境準備與安裝

可在具備 NVIDIA 顯卡（建議 VRAM ≥ 8GB）的本地電腦，或免費的 **Google Colab T4 GPU** 上執行。

Bash

```
# 1. 克隆 LLaMA-Factory 專案
git clone --depth 1 https://github.com/hiyouga/LLaMA-Factory.git
cd LLaMA-Factory

# 2. 安裝必要依賴套件
pip install -e ".[torch,metrics]"
pip install bitsandbytes hf_transfer  # 補充加速與量化套件
```

## 📝 二、 訓練資料集準備 (Dataset Preparation)

### 1. 建立格式化問答檔案 `data/citrus_disease.jsonl`

確保包含**柑橘專業知識（正向）與非相關問題拒絕回答（防護）**：

JSON

```
{"instruction": "柑橘黑星病有什麼病徵？", "input": "", "output": "主要危害果實與葉片。果實表面會出現圓形、直徑約2-5毫米的斑點，邊緣呈紅色至深褐色，中央稍微凹陷並呈灰褐色。"}
{"instruction": "請幫我寫一段 Python 快速排序法。", "input": "", "output": "抱歉，我是柑橘病蟲害防治專家，僅能回答與柑橘類樹葉病蟲害辨識與防治相關的問題。"}
```

### 2. 於 `data/dataset_info.json` 註冊資料集

打開 `LLaMA-Factory/data/dataset_info.json`，在末端新增以下區塊：

JSON

```
"citrus_disease_dataset": {
  "file_name": "citrus_disease.jsonl",
  "formatting": "sharegpt",
  "columns": {
    "messages": "messages",
    "prompt": "instruction",
    "query": "input",
    "response": "output"
  }
}
```

## 🚀 三、 啟動 WebUI 視覺化訓練 (LlamaBoard)

在終端機輸入以下命令啟動網頁介面：

Bash

```
llamafactory-cli webui
```

開啟瀏覽器進入 `http://localhost:7860`，依序設定以下參數：

### ⚙️ 關鍵訓練參數配置表

| **參數類別** | **設定項目** | **Recommended Value / 選項** | **說明** |
| --- | --- | --- | --- |
| **Model Config** | Model Language | `Chinese` | 介面語言 |
|  | Model Name | `Qwen2.5-0.5B-Instruct` | 選擇目標基礎模型 |
| **Train Config** | Stage | `sft` | 監督式微調 (Supervised Fine-Tuning) |
|  | Fine-tuning method | `lora` | 採用低秩適應，節省 VRAM |
|  | Dataset | `citrus_disease_dataset` | 勾選剛剛註冊的資料集 |
|  | Learning rate | `2e-4` 或 `5e-4` | 適合小模型的學習率 |
|  | Epochs | `3.0` ~ `5.0` | 訓練輪數 |
|  | Cutoff length | `512` | 限制上下文長度，節省顯存並對齊手機端 |
| **LoRA Config** | LoRA Rank ($r$) | `16` | 權重矩陣秩大小 |
|  | LoRA Alpha | `32` | 通常設定為 $2 \times Rank$ |
|  | LoRA Target | `all` | 作用於模型所有矩陣層 |

點擊頁面下方的 **「Start」** 開始微調，右側圖表會即時顯示 Loss（損失函數）收斂曲線。

## 🔄 四、 權重合併與 GGUF 導出 (Merge & Quantization)

訓練完成後，直接在 LLaMA-Factory WebUI 的 **「Export」** 頁籤執行導出：

1. **Export Directory**：填寫匯出路徑（例如：`./export/qwen-0.5b-citrus`）。
2. **Merge LoRA**：勾選（將微調出的 LoRA 權重無損融合回原 Base Model）。
3. **Export Quantization**：選擇 `Q4_K_M`（4-bit 量化）。
4. 點擊 **「Export」**，系統自動將 模型導出為單一的 `.gguf` 檔案（檔案大小約 300MB）。

## 📱 五、 部署至 Android 手機 APP 檢核清單

- [ ]  取得產出的 `qwen2.5-0.5b-citrus-q4_k_m.gguf` 檔案。
- [ ]  放置於 Android 專案的 `assets/models/` 目錄。
- [ ]  確認 `llama.cpp` 初始化代碼已將 `n_ctx` 設定為 `512`。
- [ ]  執行手持實機測試，驗證 2GB RAM 設備運作流暢且不觸發 OOM 閃退。

## 測試 ( 2026/8/11)

### 1. 前期準備項目 (Preparation)

- **基底模型 (Base Model)：** `Qwen2.5-0.5B-Instruct`
    - 選擇考量：小參數量（5 億參數），經 4-bit 量化後體積僅約 350MB，極度適合未來整合至 Flutter 進行手機端側（On-device）離線推論。
- **微調工具與環境：**
    - 框架：LLaMA-Factory (CLI Mode)
    - 硬體環境：WSL2 (Ubuntu) + NVIDIA RTX 4060
- **數據集構建 (Dataset)：**
    - 初期版本：89 筆柑橘病蟲害問答與角色邊界樣本（`citrus_sft.json`）。
    - 樣本結構：包含專業診斷正例（如油斑病、脂點黃斑病）、鑑別比較題，以及非相關領域的「邊界拒絕」負例（如請求寫 Python 爬蟲程式）。

### 2. 微調參數演進與調整記錄 (Parameter Tuning Log)

在微調過程中，我們觀察到小模型（0.5B）對超參數極度敏感，並經歷了以下三個主要階段的調優：

| **參數項目** | **初始嘗試 (v1)** | **第一次調整 (v2)** | **黃金平衡版 (v3/v4)** | **調整原因與影響** |
| --- | --- | --- | --- | --- |
| **Learning Rate** | `1e-4` | `5e-5` | **`3e-5`** | 高學習率易破壞基底模型的語言邏輯；調低學習率可防止過擬合與重複貼上。 |
| **Epochs** | `4.0` | `3.0` | **`2.5 ~ 3.0`** | 小數據集過多輪數會導致死記硬背，降至 2.5 輪 Loss 約在 1.35~1.5 達最佳收斂。 |
| **LoRA Rank ($r$)** | `16` | `8` | **`8`** | 容量適中，避免過度干擾基底模型神經元。 |
| **LoRA Alpha ($\alpha$)** | `32` | `16` | **`16`** | 配合 Rank 8，讓 LoRA 權重的縮放比例維持在適當強度。 |
| **LoRA Dropout** | `0` | `0` | **`0.05`** | 引入適度 Dropout 防止 Overfitting。 |
| **Batch Size (等效)** | `16` (`2`×`8`) | `4` (`2`×`2`) | **`4` (`2`×`2`)** | 縮小 Gradient Accumulation，增加每個 Epoch 的梯度更新頻率。 |
| **Cutoff Length** | `2048` | `1024` | **`1024`** | 貼合真實問答長度，節省 GPU 記憶體並提升訓練速度。 |
| **Enable Thinking** | `True` (誤開) | `False` | **`False`** |  |

### 3. 核心實務經驗與洞察 (Key Insights)

- **過度拒絕與邊界洩漏 (Boundary Trade-off)：**
小模型在資料量較少時，容易在「嚴格拒絕非相關問題」與「流暢回答專業知識」之間產生拉鋸。LoRA 權重太強會導致過度拒絕（連柑橘問題都拒絕），太弱則會產生口頭拒絕卻依然寫出程式碼的邊界洩漏。
- **System Prompt 的關鍵作用：**
推論時必須帶入與訓練集一致的 `system` 指令（`你是一位台灣柑橘類植物病蟲害專家...`），才能準確觸發模型對應的神經元與角色扮演。
- **端側部署最佳架構：**
完美的端側應用應由 **「LoRA 權重提供專業知識」**，搭配 **「System Prompt 負責邊界約束」**，並使用 **`Temperature = 0.1`** 的低隨機度進行推論。
- **數據集擴充方向：**
擴充資料量至 300~500 筆，並加入多元的「正例（柑橘知識）」與「負例（寫程式/聊天/其他作物）」，是徹底解決小模型泛化能力不足的最根本方法。