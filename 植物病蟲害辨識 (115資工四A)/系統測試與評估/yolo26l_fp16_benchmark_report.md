# yolo26l_fp16_benchmark_report

# YOLO26-large FP16 TFLite 行動端實機基準測試報告

本報告詳細記錄 **YOLO26-large (FP16 TFLite)** 模型在特定行動裝置上的 CPU 實機測試數據。

---

## 1. 測試環境與設備

| 項目 | 規格配置 |
| --- | --- |
| **測試裝置機型** | OPPO A3x |
| **處理器 (CPU)** | Snapdragon 6s 4G Gen1 Octa-core |
| **作業系統架構** | Android (aarch64) |
| **推論硬體介面** | 僅使用 CPU (啟用 XNNPACK 優化) |

---

## 2. 測試參數設定

| 參數名稱 | 設定值 | 說明 |
| --- | --- | --- |
| **模型路徑** | `/data/local/tmp/yolo26l_fp16.tflite` | 測試模型儲存位置 |
| **模型大小** | 49.93 MB | 轉換後之 FP16 半精度體積 |
| **執行緒數** | 4 Threads | CPU 推論核心使用數 |
| **GPU 委派** | 停用 (Use GPU: 0) | 未使用 GPU 加速 |
| **NNAPI 委派** | 停用 (Use NNAPI: 0) | 未使用 Android 系統級加速 |

---

## 3. 測試表現與數據分析

經過 10 次推論測試，詳細的效能與資源指標如下：

| 評估項目 | 測試數據 | 數據說明 |
| --- | --- | --- |
| **初始化時間 (Session Init)** | **458.88 ms** | 載入模型與建立執行階段所需之耗時 |
| **首輪推論延遲 (First Inference)** | **2732.15 ms** | 首次前向推論所需之耗時 (包含 Warmup 預熱) |
| **平均推論延遲 (Average Latency)** | **2719.85 ms** | 扣除首次預熱後，平均單張影像之推論延遲 |
| **最快推論延遲 (Min Latency)** | **2640.86 ms** | 測試流程中記錄之最快單次推論時間 |
| **最慢推論延遲 (Max Latency)** | **3025.40 ms** | 測試流程中記錄之最慢單次推論時間 |
| **初始化記憶體增量 (Init Memory)** | **286.73 MB** | 載入模型時所增加之記憶體空間 (Approximate) |
| **整體記憶體增量 (Overall Memory)** | **337.00 MB** | 執行測試期間，系統之最高整體記憶體增量 |
| **CPU 節點優化比例 (XNNPACK)** | **94.44%** | 成功替換 1036/1097 個運算節點以提升效率 |
| **測試迭代次數 (Iterations)** | **10** | 於基準測試期間所執行的完整推論次數 |

> [!IMPORTANT]
**行動端部署建議與分析**
* **推論效能分析**：經過模型預熱後，YOLO26-large 的平均推論延遲約為 **2.72 秒 (2719.85 ms)**。此速度（等同約 0.37 FPS）對於需要流暢畫面的即時視訊鏡頭偵測（通常要求延遲小於 100 ms）而言過於緩慢。
* **資源佔用評估**：模型載入與運行所需的記憶體增量控制在 **337.00 MB**，在中低階 Android 手機 (OPPO A3x) 的記憶體負載上處於安全範圍，無 OOM (Out of Memory) 風險。
* **部署與對比建議**：由於推論耗時較長，YOLO26-large 較不適合直接用於手機端即時畫面預覽偵測，但由於其具有最佳的精準度 (mAP50 = 87.1%)，建議將其部署於無即時性要求的手機後台異步處理任務（如使用者拍攝照片後進行高精度柑橘病蟲害分析），或是將推論端轉移至雲端伺服器運行。
> 

---

## 4. 原始測試日誌 (Raw Log)

```
07-08 15:33:55.768 I/tflite  ( 5395): Log parameter values verbosely: [0]
07-08 15:33:55.768 I/tflite  ( 5395): Min num runs: [10]
07-08 15:33:55.768 I/tflite  ( 5395): Num threads: [4]
07-08 15:33:55.769 I/tflite  ( 5395): Graph: [/data/local/tmp/yolo26l_fp16.tflite]
07-08 15:33:55.769 I/tflite  ( 5395): Signature to run: []
07-08 15:33:55.769 I/tflite  ( 5395): #threads used for CPU inference: [4]
07-08 15:33:55.769 I/tflite  ( 5395): Use gpu: [0]
07-08 15:33:55.769 I/tflite  ( 5395): Use NNAPI: [0]
07-08 15:33:55.771 I/tflite  ( 5395): Loaded model /data/local/tmp/yolo26l_fp16.tflite
07-08 15:33:55.772 I/tflite  ( 5395): Initialized TensorFlow Lite runtime.
07-08 15:33:55.786 I/tflite  ( 5395): Created TensorFlow Lite XNNPACK delegate for CPU.
07-08 15:33:55.790 I/tflite  ( 5395): Replacing 1036 out of 1097 node(s) with delegate (TfLiteXNNPackDelegate) node, yielding 23 partitions for subgraph 0.
07-08 15:33:56.228 I/tflite  ( 5395): The input model file size (MB): 49.9313
07-08 15:33:56.228 I/tflite  ( 5395): Initialized session in 458.883ms.
07-08 15:33:56.256 I/tflite  ( 5395): Running benchmark for at least 1 iterations and at least 0.5 seconds but terminate if exceeding 150 seconds.
07-08 15:33:58.992 I/tflite  ( 5395): count=1 curr=2732148 p5=2732148 median=2732148 p95=2732148
07-08 15:33:58.993 I/tflite  ( 5395): Running benchmark for at least 10 iterations and at least 1 seconds but terminate if exceeding 150 seconds.
07-08 15:34:26.201 I/tflite  ( 5395): count=10 first=2653894 curr=2709263 min=2640862 max=3025403 avg=2.71985e+06 std=105101 p5=2640862 median=2709263 p95=3025403
07-08 15:34:26.202 I/tflite  ( 5395): Inference timings in us: Init: 458883, First inference: 2732148, Warmup (avg): 2.73215e+06, Inference (avg): 2.71985e+06
07-08 15:34:26.202 I/tflite  ( 5395): Note: as the benchmark tool itself affects memory footprint, the following is only APPROXIMATE to the actual memory footprint of the model at runtime. Take the information at your discretion.
07-08 15:34:26.202 I/tflite  ( 5395): Memory footprint delta from the start of the tool (MB): init=286.73 overall=337
```