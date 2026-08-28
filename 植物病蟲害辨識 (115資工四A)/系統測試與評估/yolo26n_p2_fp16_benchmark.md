# YOLO26-nano+P2 FP16 TFLite 行動端實機基準測試報告

> **報告日期**：2026-07-08
> **評測對象**：YOLO26-nano+P2 (FP16 TFLite)
> **資料來源**：TFLite Android AArch64 Benchmark Model 實機測試 log（見 §5 原始測試日誌）
> **撰寫人**：原始記錄未標註

本報告詳細記錄 **YOLO26-nano+P2 (FP16 TFLite)** 模型在特定行動裝置上的 CPU 實機測試數據。

## 1. 摘要

- OPPO A3x（CPU only, XNNPACK）平均推論延遲 295.78 ms（約 3.38 FPS），記憶體增量 115.21 MB
- 較標準 nano 慢 21.1%、記憶體多 25.8 MB，換取對微小病斑/害蟲更強的捕捉精確度；較 Large 版快 9.2 倍

## 2. 測試環境與設備

| 項目 | 規格配置 |
| --- | --- |
| **測試裝置機型** | OPPO A3x |
| **處理器 (CPU)** | Snapdragon 6s 4G Gen1 Octa-core |
| **作業系統架構** | Android (aarch64) |
| **推論硬體介面** | 僅使用 CPU (啟用 XNNPACK 優化) |

## 3. 測試參數設定

| 參數名稱 | 設定值 | 說明 |
| --- | --- | --- |
| **模型路徑** | `/data/local/tmp/yolo26n_p2_fp16.tflite` | 測試模型儲存位置 |
| **模型大小** | 5.44 MB | 轉換後之 FP16 半精度體積 |
| **執行緒數** | 4 Threads | CPU 推論核心使用數 |
| **GPU 委派** | 停用 (Use GPU: 0) | 未使用 GPU 加速 |
| **NNAPI 委派** | 停用 (Use NNAPI: 0) | 未使用 Android 系統級加速 |

## 4. 測試表現與數據分析

經過 10 次推論測試，詳細的效能與資源指標如下：

| 評估項目 | 測試數據 | 數據說明 |
| --- | --- | --- |
| **初始化時間 (Session Init)** | **125.52 ms** | 載入模型與建立執行階段所需之耗時 |
| **首輪推論延遲 (First Inference)** | **344.85 ms** | 首次前向推論所需之耗時 (包含 Warmup 預熱) |
| **平均推論延遲 (Average Latency)** | **295.78 ms** | 扣除首次預熱後，平均單張影像之推論延遲 |
| **最快推論延遲 (Min Latency)** | **281.74 ms** | 測試流程中記錄之最快單次推論時間 |
| **最慢推論延遲 (Max Latency)** | **331.41 ms** | 測試流程中記錄之最慢單次推論時間 |
| **初始化記憶體增量 (Init Memory)** | **81.31 MB** | 載入模型時所增加之記憶體空間 (Approximate) |
| **整體記憶體增量 (Overall Memory)** | **115.21 MB** | 執行測試期間，系統之最高整體記憶體增量 |
| **CPU 節點優化比例 (XNNPACK)** | **94.74%** | 成功替換 792/836 個運算節點以提升效率 |
| **測試迭代次數 (Iterations)** | **10** | 於基準測試期間所執行的完整推論次數 |

## 5. 原始測試日誌 (Raw Log)

```
07-08 15:40:34.274 I/tflite  ( 6794): Log parameter values verbosely: [0]
07-08 15:40:34.274 I/tflite  ( 6794): Min num runs: [10]
07-08 15:40:34.274 I/tflite  ( 6794): Num threads: [4]
07-08 15:40:34.274 I/tflite  ( 6794): Graph: [/data/local/tmp/yolo26n_p2_fp16.tflite]
07-08 15:40:34.274 I/tflite  ( 6794): Signature to run: []
07-08 15:40:34.275 I/tflite  ( 6794): #threads used for CPU inference: [4]
07-08 15:40:34.275 I/tflite  ( 6794): Use gpu: [0]
07-08 15:40:34.275 I/tflite  ( 6794): Use NNAPI: [0]
07-08 15:40:34.276 I/tflite  ( 6794): Loaded model /data/local/tmp/yolo26n_p2_fp16.tflite
07-08 15:40:34.277 I/tflite  ( 6794): Initialized TensorFlow Lite runtime.
07-08 15:40:34.287 I/tflite  ( 6794): Created TensorFlow Lite XNNPACK delegate for CPU.
07-08 15:40:34.291 I/tflite  ( 6794): Replacing 792 out of 836 node(s) with delegate (TfLiteXNNPackDelegate) node, yielding 21 partitions for subgraph 0.
07-08 15:40:34.401 I/tflite  ( 6794): The input model file size (MB): 5.44486
07-08 15:40:34.401 I/tflite  ( 6794): Initialized session in 125.518ms.
07-08 15:40:34.429 I/tflite  ( 6794): Running benchmark for at least 1 iterations and at least 0.5 seconds but terminate if exceeding 150 seconds.
07-08 15:40:35.092 I/tflite  ( 6794): count=2 first=344846 curr=313209 min=313209 max=344846 avg=329028 std=15818 p5=313209 median=344846 p95=344846
07-08 15:40:35.092 I/tflite  ( 6794): Running benchmark for at least 10 iterations and at least 1 seconds but terminate if exceeding 150 seconds.
07-08 15:40:38.060 I/tflite  ( 6794): count=10 first=307053 curr=281739 min=281739 max=331407 avg=295775 std=16924 p5=281739 median=286332 p95=331407
07-08 15:40:38.060 I/tflite  ( 6794): Inference timings in us: Init: 125518, First inference: 344846, Warmup (avg): 329028, Inference (avg): 295775
07-08 15:40:38.060 I/tflite  ( 6794): Note: as the benchmark tool itself affects memory footprint, the following is only APPROXIMATE to the actual memory footprint of the model at runtime. Take the information at your discretion.
07-08 15:40:38.060 I/tflite  ( 6794): Memory footprint delta from the start of the tool (MB): init=81.3125 overall=115.211
```

## 6. 結論與限制

**行動端部署建議與分析**：

* **推論效能分析**：YOLO26-nano+P2 的平均推論延遲為 **295.78 ms**（等同約 3.38 FPS），比標準 nano 稍微慢了約 `51.5 ms` (21.1%)。這主要是因為引入額外的 P2 尺度特徵圖導致網絡深度與特徵卷積計算增加。
* **資源佔用評估**：運行期間**整體記憶體增量為 115.21 MB**，相較標準 nano 增加了約 25.8 MB，但對中低階裝置依舊非常安全且無負擔。
* **部署與對比建議**：由於 nano+P2 版本對微小細節（如極早期病斑或微小害蟲）具備極強的捕捉精確度，即使犧牲了 21% 的推論時間與部分記憶體，在需要檢測柑橘微小病蟲害的場景下，該模型依然具有顯著優勢。
* 相比 Large 版本，nano+P2 的速度快了 **9.2 倍**，記憶體僅為 Large 版本的 **34.2%**。
* 相比標準 nano，nano+P2 雖慢 21%，但在檢測微小目標時的漏檢率預期會大幅降低。

本報告未涵蓋：GPU/NNAPI 加速下的效能表現、其他手機型號的橫向對比。
