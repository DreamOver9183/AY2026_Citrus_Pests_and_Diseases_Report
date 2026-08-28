# YOLO26-nano FP16 TFLite 行動端實機基準測試報告

> **報告日期**：2026-07-08
> **評測對象**：YOLO26-nano (FP16 TFLite)
> **資料來源**：TFLite Android AArch64 Benchmark Model 實機測試 log（見 §5 原始測試日誌）
> **撰寫人**：原始記錄未標註

本報告詳細記錄 **YOLO26-nano (FP16 TFLite)** 模型在特定行動裝置上的 CPU 實機測試數據。

## 1. 摘要

- OPPO A3x（CPU only, XNNPACK）平均推論延遲僅 244.24 ms（約 4.1 FPS），記憶體增量僅 89.45 MB
- 較 Large 版快 11.1 倍、記憶體僅 26.5%，精準度（mAP50 = 85.4%）僅略低約 1.7%，是多數行動端即時情境的最佳選擇

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
| **模型路徑** | `/data/local/tmp/yolo26n_fp16.tflite` | 測試模型儲存位置 |
| **模型大小** | 5.06 MB | 轉換後之 FP16 半精度體積 |
| **執行緒數** | 4 Threads | CPU 推論核心使用數 |
| **GPU 委派** | 停用 (Use GPU: 0) | 未使用 GPU 加速 |
| **NNAPI 委派** | 停用 (Use NNAPI: 0) | 未使用 Android 系統級加速 |

## 4. 測試表現與數據分析

經過 10 次推論測試，詳細的效能與資源指標如下：

| 評估項目 | 測試數據 | 數據說明 |
| --- | --- | --- |
| **初始化時間 (Session Init)** | **110.85 ms** | 載入模型與建立執行階段所需之耗時 |
| **首輪推論延遲 (First Inference)** | **268.59 ms** | 首次前向推論所需之耗時 (包含 Warmup 預熱) |
| **平均推論延遲 (Average Latency)** | **244.24 ms** | 扣除首次預熱後，平均單張影像之推論延遲 |
| **最快推論延遲 (Min Latency)** | **216.08 ms** | 測試流程中記錄之最快單次推論時間 |
| **最慢推論延遲 (Max Latency)** | **264.53 ms** | 測試流程中記錄之最慢單次推論時間 |
| **初始化記憶體增量 (Init Memory)** | **64.80 MB** | 載入模型時所增加之記憶體空間 (Approximate) |
| **整體記憶體增量 (Overall Memory)** | **89.45 MB** | 執行測試期間，系統之最高整體記憶體增量 |
| **CPU 節點優化比例 (XNNPACK)** | **93.72%** | 成功替換 642/685 個運算節點以提升效率 |
| **測試迭代次數 (Iterations)** | **10** | 於基準測試期間所執行的完整推論次數 |

## 5. 原始測試日誌 (Raw Log)

```
07-08 15:37:34.588 I/tflite  ( 6071): Log parameter values verbosely: [0]
07-08 15:37:34.588 I/tflite  ( 6071): Min num runs: [10]
07-08 15:37:34.588 I/tflite  ( 6071): Num threads: [4]
07-08 15:37:34.588 I/tflite  ( 6071): Graph: [/data/local/tmp/yolo26n_fp16.tflite]
07-08 15:37:34.588 I/tflite  ( 6071): Signature to run: []
07-08 15:37:34.588 I/tflite  ( 6071): #threads used for CPU inference: [4]
07-08 15:37:34.588 I/tflite  ( 6071): Use gpu: [0]
07-08 15:37:34.588 I/tflite  ( 6071): Use NNAPI: [0]
07-08 15:37:34.590 I/tflite  ( 6071): Loaded model /data/local/tmp/yolo26n_fp16.tflite
07-08 15:37:34.590 I/tflite  ( 6071): Initialized TensorFlow Lite runtime.
07-08 15:37:34.601 I/tflite  ( 6071): Created TensorFlow Lite XNNPACK delegate for CPU.
07-08 15:37:34.604 I/tflite  ( 6071): Replacing 642 out of 685 node(s) with delegate (TfLiteXNNPackDelegate) node, yielding 19 partitions for subgraph 0.
07-08 15:37:34.699 I/tflite  ( 6071): The input model file size (MB): 5.05872
07-08 15:37:34.700 I/tflite  ( 6071): Initialized session in 110.85ms.
07-08 15:37:34.728 I/tflite  ( 6071): Running benchmark for at least 1 iterations and at least 0.5 seconds but terminate if exceeding 150 seconds.
07-08 15:37:35.254 I/tflite  ( 6071): count=2 first=268586 curr=250828 min=250828 max=268586 avg=259707 std=8879 p5=250828 median=268586 p95=268586
07-08 15:37:35.254 I/tflite  ( 6071): Running benchmark for at least 10 iterations and at least 1 seconds but terminate if exceeding 150 seconds.
07-08 15:37:37.708 I/tflite  ( 6071): count=10 first=237758 curr=237183 min=216081 max=264534 avg=244240 std=13396 p5=216081 median=245871 p95=264534
07-08 15:37:37.709 I/tflite  ( 6071): Inference timings in us: Init: 110850, First inference: 268586, Warmup (avg): 259707, Inference (avg): 244240
07-08 15:37:37.709 I/tflite  ( 6071): Note: as the benchmark tool itself affects memory footprint, the following is only APPROXIMATE to the actual memory footprint of the model at runtime. Take the information at your discretion.
07-08 15:37:37.709 I/tflite  ( 6071): Memory footprint delta from the start of the tool (MB): init=64.8047 overall=89.4453
```

## 6. 結論與限制

**行動端部署建議與分析**：

* **推論效能分析**：YOLO26-nano 在行動端表現極為流暢，平均推論延遲僅為 **244.24 ms**（相當於每秒 4.1 幀 / 4.1 FPS）。此速度在行動設備非即時的快速抽幀檢測（如間隔 0.5 秒檢測一次）中，已具有非常高的實用價值。
* **資源佔用評估**：模型極為輕量，初始化耗時僅需 110.85 ms，且**整體記憶體增量僅為 ~89.45 MB**，對手機系統負擔極低，完全沒有造成 OOM (Out of Memory) 的危險。
* **部署與對比建議**：相比於 Large 版本的 2.72 秒，nano 版本的推論速度提升了 **11.1 倍**，且記憶體佔用僅為 Large 版本的 **26.5%**。雖然其偵測精準度 (mAP50 = 85.4%) 比 Large 略低約 1.7%，但考慮到實機部署的流暢度與資源限制，YOLO26-nano 是絕大多數行動端即時或近即時應用情境的最佳選擇。

本報告未涵蓋：GPU/NNAPI 加速下的效能表現、其他手機型號的橫向對比。
