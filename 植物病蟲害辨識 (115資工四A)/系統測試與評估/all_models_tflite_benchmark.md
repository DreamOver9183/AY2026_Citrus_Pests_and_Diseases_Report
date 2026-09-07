# 全模型 TFLite Mobile Benchmark 效能測試報告

> **報告日期**：2026-07-14
> **評測對象**：8 個模型/精度組合（YOLO26 系列 fp16/int8、SSD-MobileNetV3 系列 fp16/fp32）
> **資料來源**：`adb logcat -s tflite` 實機測試 log（見 §6 完整輸出日誌）
> **撰寫人**：原始記錄未標註

## 1. 摘要

- 8 個模型/精度組合中，`ssd_mobilenetv3_small_fp32` 最快，平均推論 24.35 ms（41.07 FPS）；`yolo26l_fp16` 最慢，平均 2449.49 ms（0.41 FPS）。int8 量化模型（log 中檔名為 `best_int8.tflite`）為 145.53 ms（6.87 FPS）
- SSD-MobileNetV3 系列（large/small，fp16/fp32）平均推論在 24~75 ms 之間，速度優於 YOLO26 fp16 系列，但精準度遠低於 YOLO26（見〈[模型訓練數據報告](../%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%E6%A8%A1%E5%9E%8B/20260714_all_models_training_metrics.md)〉）
- YOLO26 fp16 系列中，nano（257.13 ms）與 nano+P2（284.02 ms）皆在可接受的近即時範圍內，large（2449.49 ms）明顯不適合即時場景
- XNNPACK 節點替代率介於 88.11%~98.36%，顯示絕大多數運算節點皆可由 XNNPACK 加速

| 模型 | 平均推論 (ms) | 預估 FPS |
| --- | --- | --- |
| `best_int8`（int8） | 145.53 | 6.87 |
| `yolo26n_fp16` | 257.13 | 3.89 |
| `yolo26n_p2_fp16` | 284.02 | 3.52 |
| `yolo26l_fp16` | 2449.49 | 0.41 |

## 2. 測試環境 (Environment)

- **測試設備代號 (Device ID)**: ebe3968d
- **產品型號 (Product/Model)**: CPH2641
- **設備名稱 (Device)**: OP5B16L1
- **作業系統**: Android
- **測試工具**: TFLite Android AArch64 Benchmark Model (`android_aarch64_benchmark_model.apk`)

## 3. 測試主題 (Test Topic)

- **主題**: 多模型 TFLite 推論效能比較評測
- **測試模型清單**:
    - `yolo26n_p2_w8a32.tflite`
    - `ssd_mobilenetv3_large_fp16.tflite`
    - `ssd_mobilenetv3_large_fp32.tflite`
    - `ssd_mobilenetv3_small_fp16.tflite`
    - `ssd_mobilenetv3_small_fp32.tflite`
    - `yolo26l_fp16.tflite`
    - `yolo26n_fp16.tflite`
    - `yolo26n_p2_fp16.tflite`

## 4. 測試參數 (Test Parameters)

- **硬體加速**: CPU 運算 (未使用 GPU 與 NNAPI)
- **核心數量 (num_threads)**: 4
- **推論次數 (num_runs)**: 25 輪
- **指令配置**: `-num_threads=4 --num_runs=25 --use_gpu=false --use_nnapi=false`

## 5. 輸出概要 (Output Summary)

| 模型名稱 | 首輪推論 (ms) | 最快 (ms) | 最慢 (ms) | 平均推論 (ms) | 預估 FPS | 標準差 (ms) | 節點替代率 (%) | Init 記憶體 (MB) | Overall 記憶體 (MB) | 運算開銷差值 (MB) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `best_int8.tflite` | 235.16 | 140.07 | 195.12 | 145.53 | 6.87 | 13.58 | 98.36% | 54.29 | 73.41 | 19.13 |
| `ssd_mobilenetv3_large_fp16.tflite` | 70.23 | 45.88 | 62.00 | 52.97 | 18.88 | 3.11 | 93.49% | 34.86 | 48.73 | 13.87 |
| `ssd_mobilenetv3_large_fp32.tflite` | 84.63 | 47.41 | 220.48 | 74.90 | 13.35 | 38.50 | 88.59% | 35.80 | 47.11 | 11.31 |
| `ssd_mobilenetv3_small_fp16.tflite` | 77.75 | 30.82 | 100.97 | 49.64 | 20.15 | 19.29 | 93.13% | 25.18 | 37.48 | 12.30 |
| `ssd_mobilenetv3_small_fp32.tflite` | 44.62 | 23.35 | 35.52 | 24.35 | 41.07 | 1.94 | 88.11% | 23.55 | 34.08 | 10.53 |
| `yolo26l_fp16.tflite` | 2562.79 | 2422.49 | 2510.68 | 2449.49 | 0.41 | 19.37 | 94.44% | 286.96 | 358.59 | 71.63 |
| `yolo26n_fp16.tflite` | 237.81 | 220.93 | 326.27 | 257.13 | 3.89 | 27.08 | 93.72% | 65.41 | 90.25 | 24.84 |
| `yolo26n_p2_fp16.tflite` | 321.65 | 279.65 | 310.76 | 284.02 | 3.52 | 7.78 | 94.74% | 81.23 | 115.05 | 33.82 |

> [!IMPORTANT]
> **2026-09-07 數據更正。** 依 §6 所附原始 log 的 `count=25` 與 `Memory footprint` 兩行逐欄重新比對後，
> 上表有兩列與自己的 log 不符，已更正：
>
> - **第 1 列**：原記為 `yolo26n_p2_w8a32.tflite`，但**該檔名在 §6 全部原始 log 中從未出現**，
>   該批次實際載入的是 `best_int8.tflite`，十個欄位無一相符（原記平均 16.53 ms / 60.50 FPS，
>   實為 145.53 ms / 6.87 FPS）。log 只留下檔名與「輸入模型檔案大小 3.06 MB」，
>   **不足以判定它對應哪一個訓練版本**，故此處僅照 log 記為 `best_int8.tflite`，不另標型號。
> - **第 2 列**：`ssd_mobilenetv3_large_fp16.tflite` 十個欄位中有八個與自己的 log 不符
>   （其節點替代率 88.59% 是 fp32 那一列的值）。
> - 其餘六列與各自的 log 相符，未更動。
> - `yolo26l_fp16` 的節點替代率 94.44% 在 §6 的 log 摘錄中沒有對應的 `Replacing` 行，
>   **無法自 log 驗證**，因此維持原值不動。
>
> 更正同步套用於 §1 摘要與 §7 結論。此更正只改上述兩列與受其影響的敘述，其餘內容未動。

> [!NOTE]
**欄位指標說明：**
* **首輪推論 (First Inference)**：模型載入後第一次進行推論的耗時，反映按下按鈕時是否會遇到「首幀卡頓」。
* **預估 FPS (Estimated FPS)**：基於平均推論時間推算的每秒吞吐量，公式為 `1000 / 平均推論 (ms)`。
* **標準差 (Std Dev)**：反映推論速度的波動程度；數值越低代表運行越穩定。
* **節點替代率 (Delegate Ratio)**：被 XNNPACK 接管的運算節點比例。比例過低代表存在許多設備不支援的自定義算子。
* **運算開銷差值**：`Overall 記憶體增量` 減去 `Init 記憶體增量`，顯示推論過程中因暫存特徵圖所額外佔用的記憶體峰值。

## 6. 完整輸出日誌 (Full Output Log)

*(在此收錄每個模型透過 `adb logcat -d -s tflite` 產生的原始 Log 資訊，確保數據具備可追溯性。)*

- **模型：yolo26n_p2_w8a32.tflite**

    ```
    07-14 13:14:52.097 22838 22838 I tflite  : Log parameter values verbosely: [0]
    07-14 13:14:52.097 22838 22838 I tflite  : Min num runs: [25]
    07-14 13:14:52.097 22838 22838 I tflite  : Num threads: [4]
    07-14 13:14:52.097 22838 22838 I tflite  : Graph: [/data/local/tmp/best_int8.tflite]
    07-14 13:14:52.097 22838 22838 I tflite  : Signature to run: []
    07-14 13:14:52.097 22838 22838 I tflite  : #threads used for CPU inference: [4]
    07-14 13:14:52.097 22838 22838 I tflite  : Use gpu: [0]
    07-14 13:14:52.097 22838 22838 I tflite  : Use NNAPI: [0]
    07-14 13:14:52.098 22838 22838 I tflite  : Loaded model /data/local/tmp/best_int8.tflite
    07-14 13:14:52.099 22838 22838 I tflite  : Initialized TensorFlow Lite runtime.
    07-14 13:14:52.113 22838 22838 I tflite  : Created TensorFlow Lite XNNPACK delegate for CPU.
    07-14 13:14:52.115 22838 22838 I tflite  : Replacing 539 out of 548 node(s) with delegate (TfLiteXNNPackDelegate) node, yielding 19 partitions for subgraph 0.
    07-14 13:14:52.190 22838 22838 I tflite  : The input model file size (MB): 3.06409
    07-14 13:14:52.190 22838 22838 I tflite  : Initialized session in 92.318ms.
    07-14 13:14:52.218 22838 22838 I tflite  : Running benchmark for at least 1 iterations and at least 0.5 seconds but terminate if exceeding 150 seconds.
    07-14 13:14:52.859 22838 22838 I tflite  : count=3 first=235158 curr=200386 min=199462 max=235158 avg=211669 std=16613 p5=199462 median=200386 p95=235158
    07-14 13:14:52.859 22838 22838 I tflite  : Running benchmark for at least 25 iterations and at least 1 seconds but terminate if exceeding 150 seconds.
    07-14 13:14:56.520 22838 22838 I tflite  : count=25 first=187533 curr=140990 min=140071 max=195121 avg=145528 std=13583 p5=140545 median=141253 p95=187533
    07-14 13:14:56.521 22838 22838 I tflite  : Inference timings in us: Init: 92318, First inference: 235158, Warmup (avg): 211669, Inference (avg): 145528
    07-14 13:14:56.521 22838 22838 I tflite  : Note: as the benchmark tool itself affects memory footprint, the following is only APPROXIMATE to the actual memory footprint of the model at runtime. Take the information at your discretion.
    07-14 13:14:56.521 22838 22838 I tflite  : Memory footprint delta from the start of the tool (MB): init=54.2852 overall=73.4102
    ```

- **模型：ssd_mobilenetv3_large_fp16.tflite**

    ```
    07-14 13:16:26.182 23002 23002 I tflite  : Log parameter values verbosely: [0]
    07-14 13:16:26.182 23002 23002 I tflite  : Min num runs: [25]
    07-14 13:16:26.182 23002 23002 I tflite  : Num threads: [4]
    07-14 13:16:26.182 23002 23002 I tflite  : Graph: [/data/local/tmp/ssd_mobilenetv3_large_fp16.tflite]
    07-14 13:16:26.182 23002 23002 I tflite  : Signature to run: []
    07-14 13:16:26.182 23002 23002 I tflite  : #threads used for CPU inference: [4]
    07-14 13:16:26.182 23002 23002 I tflite  : Use gpu: [0]
    07-14 13:16:26.182 23002 23002 I tflite  : Use NNAPI: [0]
    07-14 13:16:26.184 23002 23002 I tflite  : Loaded model /data/local/tmp/ssd_mobilenetv3_large_fp16.tflite
    07-14 13:16:26.184 23002 23002 I tflite  : Initialized TensorFlow Lite runtime.
    07-14 13:16:26.193 23002 23002 I tflite  : Created TensorFlow Lite XNNPACK delegate for CPU.
    07-14 13:16:26.195 23002 23002 I tflite  : Replacing 431 out of 461 node(s) with delegate (TfLiteXNNPackDelegate) node, yielding 58 partitions for subgraph 0.
    07-14 13:16:26.241 23002 23002 I tflite  : The input model file size (MB): 4.7767
    07-14 13:16:26.241 23002 23002 I tflite  : Initialized session in 58.312ms.
    07-14 13:16:26.248 23002 23002 I tflite  : Running benchmark for at least 1 iterations and at least 0.5 seconds but terminate if exceeding 150 seconds.
    07-14 13:16:26.766 23002 23002 I tflite  : count=9 first=70225 curr=58557 min=54075 max=70225 avg=57237.2 std=4816 p5=54075 median=55355 p95=70225
    07-14 13:16:26.766 23002 23002 I tflite  : Running benchmark for at least 25 iterations and at least 1 seconds but terminate if exceeding 150 seconds.
    07-14 13:16:28.097 23002 23002 I tflite  : count=25 first=53752 curr=45884 min=45884 max=62002 avg=52970 std=3114 p5=46034 median=53524 p95=55365
    07-14 13:16:28.097 23002 23002 I tflite  : Inference timings in us: Init: 58312, First inference: 70225, Warmup (avg): 57237.2, Inference (avg): 52970
    07-14 13:16:28.097 23002 23002 I tflite  : Note: as the benchmark tool itself affects memory footprint, the following is only APPROXIMATE to the actual memory footprint of the model at runtime. Take the information at your discretion.
    07-14 13:16:28.097 23002 23002 I tflite  : Memory footprint delta from the start of the tool (MB): init=34.8633 overall=48.7305
    ```

- **模型：ssd_mobilenetv3_large_fp32.tflite**

    ```
    07-14 13:18:38.406 23449 23449 I tflite  : Log parameter values verbosely: [0]
    07-14 13:18:38.406 23449 23449 I tflite  : Min num runs: [25]
    07-14 13:18:38.406 23449 23449 I tflite  : Num threads: [4]
    07-14 13:18:38.407 23449 23449 I tflite  : Graph: [/data/local/tmp/ssd_mobilenetv3_large_fp32.tflite]
    07-14 13:18:38.407 23449 23449 I tflite  : Signature to run: []
    07-14 13:18:38.407 23449 23449 I tflite  : #threads used for CPU inference: [4]
    07-14 13:18:38.407 23449 23449 I tflite  : Use gpu: [0]
    07-14 13:18:38.407 23449 23449 I tflite  : Use NNAPI: [0]
    07-14 13:18:38.408 23449 23449 I tflite  : Loaded model /data/local/tmp/ssd_mobilenetv3_large_fp32.tflite
    07-14 13:18:38.409 23449 23449 I tflite  : Initialized TensorFlow Lite runtime.
    07-14 13:18:38.425 23449 23449 I tflite  : Created TensorFlow Lite XNNPACK delegate for CPU.
    07-14 13:18:38.426 23449 23449 I tflite  : Replacing 233 out of 263 node(s) with delegate (TfLiteXNNPackDelegate) node, yielding 58 partitions for subgraph 0.
    07-14 13:18:38.455 23449 23449 I tflite  : The input model file size (MB): 9.43909
    07-14 13:18:38.455 23449 23449 I tflite  : Initialized session in 47.882ms.
    07-14 13:18:38.462 23449 23449 I tflite  : Running benchmark for at least 1 iterations and at least 0.5 seconds but terminate if exceeding 150 seconds.
    07-14 13:18:38.970 23449 23449 I tflite  : count=4 first=84630 curr=168669 min=84630 max=168669 avg=126596 std=32540 p5=84630 median=145308 p95=168669
    07-14 13:18:38.970 23449 23449 I tflite  : Running benchmark for at least 25 iterations and at least 1 seconds but terminate if exceeding 150 seconds.
    07-14 13:18:40.851 23449 23449 I tflite  : count=25 first=220482 curr=47795 min=47408 max=220482 avg=74900.7 std=38502 p5=47464 median=58959 p95=136481
    07-14 13:18:40.851 23449 23449 I tflite  : Inference timings in us: Init: 47882, First inference: 84630, Warmup (avg): 126596, Inference (avg): 74900.7
    07-14 13:18:40.851 23449 23449 I tflite  : Note: as the benchmark tool itself affects memory footprint, the following is only APPROXIMATE to the actual memory footprint of the model at runtime. Take the information at your discretion.
    07-14 13:18:40.851 23449 23449 I tflite  : Memory footprint delta from the start of the tool (MB): init=35.7969 overall=47.1055
    ```

- **模型：ssd_mobilenetv3_small_fp16.tflite**

    ```
    07-14 13:19:38.427 24138 24138 I tflite  : Log parameter values verbosely: [0]
    07-14 13:19:38.428 24138 24138 I tflite  : Min num runs: [25]
    07-14 13:19:38.428 24138 24138 I tflite  : Num threads: [4]
    07-14 13:19:38.428 24138 24138 I tflite  : Graph: [/data/local/tmp/ssd_mobilenetv3_small_fp16.tflite]
    07-14 13:19:38.428 24138 24138 I tflite  : Signature to run: []
    07-14 13:19:38.428 24138 24138 I tflite  : #threads used for CPU inference: [4]
    07-14 13:19:38.428 24138 24138 I tflite  : Use gpu: [0]
    07-14 13:19:38.428 24138 24138 I tflite  : Use NNAPI: [0]
    07-14 13:19:38.429 24138 24138 I tflite  : Loaded model /data/local/tmp/ssd_mobilenetv3_small_fp16.tflite
    07-14 13:19:38.430 24138 24138 I tflite  : Initialized TensorFlow Lite runtime.
    07-14 13:19:38.441 24138 24138 I tflite  : Created TensorFlow Lite XNNPACK delegate for CPU.
    07-14 13:19:38.443 24138 24138 I tflite  : Replacing 393 out of 422 node(s) with delegate (TfLiteXNNPackDelegate) node, yielding 56 partitions for subgraph 0.
    07-14 13:19:38.484 24138 24138 I tflite  : The input model file size (MB): 3.36797
    07-14 13:19:38.484 24138 24138 I tflite  : Initialized session in 55.307ms.
    07-14 13:19:38.492 24138 24138 I tflite  : Running benchmark for at least 1 iterations and at least 0.5 seconds but terminate if exceeding 150 seconds.
    07-14 13:19:38.996 24138 24138 I tflite  : count=11 first=77746 curr=36511 min=33085 max=77746 avg=45318.1 std=11724 p5=33085 median=41156 p95=77746
    07-14 13:19:38.996 24138 24138 I tflite  : Running benchmark for at least 25 iterations and at least 1 seconds but terminate if exceeding 150 seconds.
    07-14 13:19:40.245 24138 24138 I tflite  : count=25 first=42212 curr=98689 min=30816 max=100971 avg=49635.4 std=19292 p5=31384 median=43521 p95=98689
    07-14 13:19:40.245 24138 24138 I tflite  : Inference timings in us: Init: 55307, First inference: 77746, Warmup (avg): 45318.1, Inference (avg): 49635.4
    07-14 13:19:40.245 24138 24138 I tflite  : Note: as the benchmark tool itself affects memory footprint, the following is only APPROXIMATE to the actual memory footprint of the model at runtime. Take the information at your discretion.
    07-14 13:19:40.245 24138 24138 I tflite  : Memory footprint delta from the start of the tool (MB): init=25.1797 overall=37.4805
    ```

- **模型：ssd_mobilenetv3_small_fp32.tflite**

    ```
    07-14 13:20:56.221 24964 24964 I tflite  : Log parameter values verbosely: [0]
    07-14 13:20:56.221 24964 24964 I tflite  : Min num runs: [25]
    07-14 13:20:56.221 24964 24964 I tflite  : Num threads: [4]
    07-14 13:20:56.221 24964 24964 I tflite  : Graph: [/data/local/tmp/ssd_mobilenetv3_small_fp32.tflite]
    07-14 13:20:56.221 24964 24964 I tflite  : Signature to run: []
    07-14 13:20:56.221 24964 24964 I tflite  : #threads used for CPU inference: [4]
    07-14 13:20:56.222 24964 24964 I tflite  : Use gpu: [0]
    07-14 13:20:56.222 24964 24964 I tflite  : Use NNAPI: [0]
    07-14 13:20:56.223 24964 24964 I tflite  : Loaded model /data/local/tmp/ssd_mobilenetv3_small_fp32.tflite
    07-14 13:20:56.223 24964 24964 I tflite  : Initialized TensorFlow Lite runtime.
    07-14 13:20:56.232 24964 24964 I tflite  : Created TensorFlow Lite XNNPACK delegate for CPU.
    07-14 13:20:56.233 24964 24964 I tflite  : Replacing 215 out of 244 node(s) with delegate (TfLiteXNNPackDelegate) node, yielding 56 partitions for subgraph 0.
    07-14 13:20:56.251 24964 24964 I tflite  : The input model file size (MB): 6.63153
    07-14 13:20:56.251 24964 24964 I tflite  : Initialized session in 29.239ms.
    07-14 13:20:56.258 24964 24964 I tflite  : Running benchmark for at least 1 iterations and at least 0.5 seconds but terminate if exceeding 150 seconds.
    07-14 13:20:56.769 24964 24964 I tflite  : count=20 first=44621 curr=23614 min=23134 max=44621 avg=25314.2 std=4547 p5=23295 median=24057 p95=44621
    07-14 13:20:56.770 24964 24964 I tflite  : Running benchmark for at least 25 iterations and at least 1 seconds but terminate if exceeding 150 seconds.
    07-14 13:20:57.778 24964 24964 I tflite  : count=41 first=26457 curr=23736 min=23347 max=35524 avg=24347.7 std=1945 p5=23412 median=23757 p95=26457
    07-14 13:20:57.779 24964 24964 I tflite  : Inference timings in us: Init: 29239, First inference: 44621, Warmup (avg): 25314.2, Inference (avg): 24347.7
    07-14 13:20:57.779 24964 24964 I tflite  : Note: as the benchmark tool itself affects memory footprint, the following is only APPROXIMATE to the actual memory footprint of the model at runtime. Take the information at your discretion.
    07-14 13:20:57.779 24964 24964 I tflite  : Memory footprint delta from the start of the tool (MB): init=23.5469 overall=34.0781
    ```

- **模型：yolo26l_fp16.tflite**

    ```
    07-14 13:23:01.971 25113 25113 I tflite  : count=25 first=2440784 curr=2510677 min=2422486 max=2510677 avg=2.44949e+06 std=19367 p5=2423455 median=2447822 p95=2491568
    07-14 13:23:01.971 25113 25113 I tflite  : Inference timings in us: Init: 450850, First inference: 2562790, Warmup (avg): 2.56279e+06, Inference (avg): 2.44949e+06
    07-14 13:23:01.971 25113 25113 I tflite  : Note: as the benchmark tool itself affects memory footprint, the following is only APPROXIMATE to the actual memory footprint of the model at runtime. Take the information at your discretion.
    07-14 13:23:01.971 25113 25113 I tflite  : Memory footprint delta from the start of the tool (MB): init=286.961 overall=358.59
    ```

- **模型：yolo26n_fp16.tflite**

    ```
    07-14 13:23:08.133 25289 25289 I tflite  : Log parameter values verbosely: [0]
    07-14 13:23:08.133 25289 25289 I tflite  : Min num runs: [25]
    07-14 13:23:08.133 25289 25289 I tflite  : Num threads: [4]
    07-14 13:23:08.133 25289 25289 I tflite  : Graph: [/data/local/tmp/yolo26n_fp16.tflite]
    07-14 13:23:08.133 25289 25289 I tflite  : Signature to run: []
    07-14 13:23:08.134 25289 25289 I tflite  : #threads used for CPU inference: [4]
    07-14 13:23:08.134 25289 25289 I tflite  : Use gpu: [0]
    07-14 13:23:08.134 25289 25289 I tflite  : Use NNAPI: [0]
    07-14 13:23:08.135 25289 25289 I tflite  : Loaded model /data/local/tmp/yolo26n_fp16.tflite
    07-14 13:23:08.136 25289 25289 I tflite  : Initialized TensorFlow Lite runtime.
    07-14 13:23:08.145 25289 25289 I tflite  : Created TensorFlow Lite XNNPACK delegate for CPU.
    07-14 13:23:08.148 25289 25289 I tflite  : Replacing 642 out of 685 node(s) with delegate (TfLiteXNNPackDelegate) node, yielding 19 partitions for subgraph 0.
    07-14 13:23:08.229 25289 25289 I tflite  : The input model file size (MB): 5.05872
    07-14 13:23:08.229 25289 25289 I tflite  : Initialized session in 95.112ms.
    07-14 13:23:08.257 25289 25289 I tflite  : Running benchmark for at least 1 iterations and at least 0.5 seconds but terminate if exceeding 150 seconds.
    07-14 13:23:08.980 25289 25289 I tflite  : count=3 first=237814 curr=236852 min=236852 max=242195 avg=238954 std=2325 p5=236852 median=237814 p95=242195
    07-14 13:23:08.980 25289 25289 I tflite  : Running benchmark for at least 25 iterations and at least 1 seconds but terminate if exceeding 150 seconds.
    07-14 13:23:15.443 25289 25289 I tflite  : count=25 first=243180 curr=227146 min=220934 max=326273 avg=257131 std=27081 p5=226088 median=252767 p95=303407
    07-14 13:23:15.443 25289 25289 I tflite  : Inference timings in us: Init: 95112, First inference: 237814, Warmup (avg): 238954, Inference (avg): 257131
    07-14 13:23:15.443 25289 25289 I tflite  : Note: as the benchmark tool itself affects memory footprint, the following is only APPROXIMATE to the actual memory footprint of the model at runtime. Take the information at your discretion.
    07-14 13:23:15.443 25289 25289 I tflite  : Memory footprint delta from the start of the tool (MB): init=65.4141 overall=90.25
    ```

- **模型：yolo26n_p2_fp16.tflite**

    ```
    07-14 14:01:32.208 30655 30655 I tflite  : Log parameter values verbosely: [0]
    07-14 14:01:32.208 30655 30655 I tflite  : Min num runs: [25]
    07-14 14:01:32.208 30655 30655 I tflite  : Num threads: [4]
    07-14 14:01:32.208 30655 30655 I tflite  : Graph: [/data/local/tmp/yolo26n_p2_fp16.tflite]
    07-14 14:01:32.208 30655 30655 I tflite  : Signature to run: []
    07-14 14:01:32.208 30655 30655 I tflite  : #threads used for CPU inference: [4]
    07-14 14:01:32.208 30655 30655 I tflite  : Use gpu: [0]
    07-14 14:01:32.208 30655 30655 I tflite  : Use NNAPI: [0]
    07-14 14:01:32.210 30655 30655 I tflite  : Loaded model /data/local/tmp/yolo26n_p2_fp16.tflite
    07-14 14:01:32.210 30655 30655 I tflite  : Initialized TensorFlow Lite runtime.
    07-14 14:01:32.220 30655 30655 I tflite  : Created TensorFlow Lite XNNPACK delegate for CPU.
    07-14 14:01:32.224 30655 30655 I tflite  : Replacing 792 out of 836 node(s) with delegate (TfLiteXNNPackDelegate) node, yielding 21 partitions for subgraph 0.
    07-14 14:01:32.333 30655 30655 I tflite  : The input model file size (MB): 5.44486
    07-14 14:01:32.333 30655 30655 I tflite  : Initialized session in 123.966ms.
    07-14 14:01:32.361 30655 30655 I tflite  : Running benchmark for at least 1 iterations and at least 0.5 seconds but terminate if exceeding 150 seconds.
    07-14 14:01:33.001 30655 30655 I tflite  : count=2 first=321652 curr=313833 min=313833 max=321652 avg=317742 std=3909 p5=313833 median=321652 p95=321652
    07-14 14:01:33.001 30655 30655 I tflite  : Running benchmark for at least 25 iterations and at least 1 seconds but terminate if exceeding 150 seconds.
    07-14 14:01:40.124 30655 30655 I tflite  : count=25 first=310759 curr=280378 min=279652 max=310759 avg=284021 std=7781 p5=279713 median=280999 p95=306309
    07-14 14:01:40.124 30655 30655 I tflite  : Inference timings in us: Init: 123966, First inference: 321652, Warmup (avg): 317742, Inference (avg): 284021
    07-14 14:01:40.124 30655 30655 I tflite  : Note: as the benchmark tool itself affects memory footprint, the following is only APPROXIMATE to the actual memory footprint of the model at runtime. Take the information at your discretion.
    07-14 14:01:40.124 30655 30655 I tflite  : Memory footprint delta from the start of the tool (MB): init=81.2305 overall=115.047
    ```

## 7. 結論與限制

8 個模型/精度組合中，`ssd_mobilenetv3_small_fp32` 速度最快、`yolo26l_fp16` 最慢；SSD 系列雖速度尚可但精準度明顯低於 YOLO26 系列（詳細精準度數據見〈模型訓練數據報告〉）。單一裝置（CPH2641）、單一執行緒設定（4 threads、CPU only）下的結果，僅反映相對排序，不代表所有裝置的絕對表現。

本報告未涵蓋：GPU/NNAPI 加速下的效能表現、其他手機型號的橫向對比、量化模型（int8）的精準度數據。
