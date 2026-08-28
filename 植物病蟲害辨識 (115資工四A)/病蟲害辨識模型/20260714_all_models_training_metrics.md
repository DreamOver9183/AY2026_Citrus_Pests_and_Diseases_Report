# 模型訓練數據報告

**報告日期**：2026-07-14

**報告類型**：模型訓練數據報告

**評估對象**：
- YOLO26 系列目標偵測模型（Large, Nano, Nano+P2, 量化微調版）
- 基於 PyTorch 的 SSD-MobileNetV3 系列目標偵測模型（Large, Small）。

**資料集規格**：作物病蟲害偵測資料集。

---

## 1. 數據總覽 (Metrics Overview)

下表彙整了所有評估模型在驗證集上的最優效能指標。
其中，[**mAP@50](mailto:mAP@50) (IoU=0.5)** 代表粗定位與分類的綜合平均精度；[**mAP@50](mailto:mAP@50):95** 代表精密邊界框定位能力；**準確率 (Accuracy)** 則採用邊界框級別的交併比匹配度公式計算（以 $TN = 0$ 為簡化標準）。
*註：SSD-MobileNetV3 模型的 Precision, Recall、F1-Score 與 Accuracy 係經由驗證集上進行完整推論匹配計算得出（以最優 F1-Score 對應的置信度閾值 0.20 為準）。*

| 模型名稱 (Model) | 準確率 (Accuracy) | 精確率 (Precision) | 召回率 (Recall) | F1-Score | [mAP@50](mailto:mAP@50) (IoU=0.5) | [mAP@50-95](mailto:mAP@50-95) | 訓練輪數 (Epoch) | 權重大小 (Size) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **YOLO26-large** | **0.7701** | 0.8983 | 0.8436 | 0.8701 | **0.8711** | 0.7436 | 109 | ~50.7 MB |
| **YOLO26-nano** | 0.7326 | 0.8680 | 0.8244 | 0.8456 | 0.8544 | 0.7205 | 124 | ~5.3 MB |
| **YOLO26-nano+P2** | 0.7441 | 0.8770 | 0.8308 | 0.8533 | 0.8511 | 0.7201 | 98 | ~5.3 MB |
| **YOLO26-nano-p2-w8a32** | 0.7200 | 0.8662 | 0.8101 | 0.8372 | 0.8463 | 0.7132 | 7 (微調) | ~5.3 MB |
| **SSD-MobileNetV3-large** | 0.0897 | 0.1870 | 0.1471 | 0.1647 | 0.4717 | 0.3269 | 45 | ~9.3 MB |
| **SSD-MobileNetV3-small** | 0.0731 | 0.3422 | 0.0850 | 0.1362 | 0.4541 | 0.2676 | 45 | ~6.8 MB |

---

## 2. 數據計算與匹配邏輯說明

本報告之所有數據皆經由工作區之真實訓練日誌（`results.csv` 與 `training_metrics.csv`）提取或經由原始權重評估得出。

### 1. 核心評估指標公式

#### (1) 準確率 (Accuracy)

在目標偵測任務中，因無效背景框數 ($\text{TN}$) 為無限且不可統計，若將其簡化為 $\text{TN} = 0$（即不計入無目標的背景區域），則準確率公式簡化為邊界框級別的匹配度：

$$
\text{Accuracy} = \frac{\text{TP} + \text{TN}}{\text{TP} + \text{FP} + \text{FN} + \text{TN}} \xrightarrow{\text{TN} = 0} \frac{\text{TP}}{\text{TP} + \text{FP} + \text{FN}}
$$

#### 【公式推導過程】

利用精確率 (

$\text{Precision}$

) 與召回率 (

$\text{Recall}$

) 的數學定義關係：

$$
\text{Precision} = \frac{\text{TP}}{\text{TP} + \text{FP}} \implies \text{TP} + \text{FP} = \frac{\text{TP}}{\text{Precision}}
$$

$$
\text{Recall} = \frac{\text{TP}}{\text{TP} + \text{FN}} \implies \text{TP} + \text{FN} = \frac{\text{TP}}{\text{Recall}}
$$

將上式代入分母

$\text{TP} + \text{FP} + \text{FN}$

：

$$
\text{TP} + \text{FP} + \text{FN} = (\text{TP} + \text{FP}) + (\text{TP} + \text{FN}) - \text{TP}
$$

$$
\text{TP} + \text{FP} + \text{FN} = \frac{\text{TP}}{\text{Precision}} + \frac{\text{TP}}{\text{Recall}} - \text{TP}
$$

代入後將分子與分母同除以

$\text{TP}$

，即可將其轉換為以下與 Precision 和 Recall 相關的公式：

$$
\text{Accuracy} = \frac{\text{TP}}{\frac{\text{TP}}{\text{Precision}} + \frac{\text{TP}}{\text{Recall}} - \text{TP}} = \frac{1}{\frac{1}{\text{Precision}} + \frac{1}{\text{Recall}} - 1}
$$

#### (2) 精確率 (Precision)

模型預測出的所有目標中，預測正確的比例：

$$
\text{Precision} = \frac{\text{TP}}{\text{TP} + \text{FP}}
$$

#### (3) 召回率 (Recall)

驗證集中所有真實存在的目標中，被模型成功檢出的比例：

$$
\text{Recall} = \frac{\text{TP}}{\text{TP} + \text{FN}}
$$

#### (4) F1-Score

精確率與召回率的調和平均數：

$$
\text{F1-Score} = 2 \times \frac{\text{Precision} \times \text{Recall}}{\text{Precision} + \text{Recall}}
$$

#### (5) 交併比 (Intersection over Union, IoU)

用於衡量預測框 $A$ 與真實框 $B$ 的重疊程度：

$$
\text{IoU} = \frac{\text{Area}(A \cap B)}{\text{Area}(A \cup B)} = \frac{\text{Area of Intersection}}{\text{Area of Union}}
$$

當 $\text{IoU} \ge 0.5$ 且預測類別正確時，該預測框被判定為候選正確預測。

#### (6) 平均精度 ([mAP@50](mailto:mAP@50) 與 [mAP@50-95](mailto:mAP@50-95))

- [**mAP@50**](mailto:mAP@50)：在 IoU 閾值固定為 $0.5$ 時，所有類別 AP 的平均值，用於評估粗定位與分類性能。
- [**mAP@50-95**](mailto:mAP@50-95)：在 IoU 閾值從 $0.5$ 漸進到 $0.95$（步長為 $0.05$）下分別計算 mAP，最後再取平均值，用於評估精密定位性能。

---

### 2. 評估與匹配細則

- **YOLO26 數據**：直接自 `results.csv` 中提取最優 Epoch 之各項 metrics，並以上述 F1-Score 公式計算。
- **SSD-MobileNetV3 數據**：使用評估腳本（`evaluate_ssd.py`）在驗證集上進行完整推論。
- **匹配邏輯**：
    1. 對模型預測出的邊界框，依置信度（Confidence Score）從高到低進行排序。
    2. 只保留置信度大於等於特定閾值（如 $0.20$）的預測框。
    3. 對於每個預測框，尋找與其類別相同且 IoU 最大的真實框：
        - 若最大 $\text{IoU} \ge 0.5$ 且該真實框未被匹配過，則計為 **TP (True Positive)**，並將該真實框標記為已匹配。
        - 若 $\text{IoU} < 0.5$ 或該真實框已被匹配，則計為 **FP (False Positive)**。
    4. 遍歷完畢後，所有未被匹配的真實框皆計為 **FN (False Negative)**。

---

## 3. YOLO26 系列詳細數據

YOLO26 系列模型在不同訓練階段的關鍵數據如下表所示：

### 1. YOLO26-large 詳細訓練軌跡

- **最優狀態**：Epoch 109 達到最優。
- **指標數值**：[mAP@50](mailto:mAP@50) = 0.8711，[mAP@50](mailto:mAP@50):95 = 0.7436，F1-Score = 0.8701。

| Epoch | Train Box Loss | Train Cls Loss | Precision | Recall | [mAP@50](mailto:mAP@50) | [mAP@50](mailto:mAP@50):95 | Val Box Loss | Val Cls Loss |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 1.2219 | 2.4264 | 0.6936 | 0.7282 | 0.7549 | 0.6182 | 1.2189 | 1.1985 |
| 10 | 1.2577 | 1.1777 | 0.8021 | 0.8046 | 0.8254 | 0.6624 | 1.2456 | 0.9247 |
| 20 | 1.1531 | 0.9362 | 0.8116 | 0.8291 | 0.8522 | 0.7078 | 1.1055 | 0.7615 |
| 50 | 0.9968 | 0.6791 | 0.8722 | 0.8392 | 0.8771 | 0.7353 | 1.0035 | 0.6696 |
| 80 | 0.8699 | 0.5247 | 0.8752 | 0.8507 | 0.8743 | 0.7425 | 0.9350 | 0.6377 |
| 100 | 0.7903 | 0.4353 | 0.8919 | 0.8426 | 0.8709 | 0.7454 | 0.9113 | 0.6109 |
| **109** | 0.7577 | 0.4179 | 0.8983 | 0.8436 | 0.8711 | 0.7436 | 0.9108 | 0.6104 |

*結果圖表參考*

：
- 綜合訓練結果：

![Results](20260714_all_models_training_metrics/yolo26l_results.png)

- PR 曲線：

![PR Curve](20260714_all_models_training_metrics/yolo26l_pr_curve.png)

- F1 曲線：

![F1 Curve](20260714_all_models_training_metrics/yolo26l_f1_curve.png)

- 混淆矩陣：

![Confusion Matrix](20260714_all_models_training_metrics/yolo26l_confusion_matrix_norm.png)

### 2. YOLO26-nano 詳細訓練軌跡

- **最優狀態**：Epoch 124 達到最優。
- **指標數值**：[mAP@50](mailto:mAP@50) = 0.8544，[mAP@50](mailto:mAP@50):95 = 0.7205，F1-Score = 0.8456。

| Epoch | Train Box Loss | Train Cls Loss | Precision | Recall | [mAP@50](mailto:mAP@50) | [mAP@50](mailto:mAP@50):95 | Val Box Loss | Val Cls Loss |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 1.3987 | 3.6041 | 0.6088 | 0.6163 | 0.6367 | 0.5376 | 1.3513 | 1.7553 |
| 10 | 1.3696 | 1.1928 | 0.7881 | 0.7657 | 0.8010 | 0.6464 | 1.4296 | 1.1229 |
| 20 | 1.2822 | 0.9990 | 0.8212 | 0.7986 | 0.8275 | 0.6715 | 1.3459 | 0.9356 |
| 50 | 1.1658 | 0.7751 | 0.8556 | 0.8271 | 0.8504 | 0.7085 | 1.1910 | 0.7394 |
| 80 | 1.0752 | 0.6653 | 0.8530 | 0.8218 | 0.8531 | 0.7178 | 1.1394 | 0.7141 |
| 100 | 1.0056 | 0.5899 | 0.8618 | 0.8305 | 0.8571 | 0.7190 | 1.1257 | 0.7155 |
| **124** | 0.9461 | 0.5370 | 0.8679 | 0.8244 | 0.8544 | 0.7205 | 1.1154 | 0.7227 |

*結果圖表參考*

：
- 綜合訓練結果：

![Results](20260714_all_models_training_metrics/yolo26n_results.png)

- PR 曲線：

![PR Curve](20260714_all_models_training_metrics/yolo26n_pr_curve.png)

- 混淆矩陣：

![Confusion Matrix](20260714_all_models_training_metrics/yolo26n_confusion_matrix_norm.png)

### 3. YOLO26-nano+P2 詳細訓練軌跡

- **最優狀態**：Epoch 98 達到最優。
- **指標數值**：[mAP@50](mailto:mAP@50) = 0.8511，[mAP@50](mailto:mAP@50):95 = 0.7201，F1-Score = 0.8533。

| Epoch | Train Box Loss | Train Cls Loss | Precision | Recall | [mAP@50](mailto:mAP@50) | [mAP@50](mailto:mAP@50):95 | Val Box Loss | Val Cls Loss |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 2.5204 | 4.9543 | 0.3572 | 0.3959 | 0.3223 | 0.1936 | 1.7552 | 2.7031 |
| 10 | 1.4027 | 1.3980 | 0.7433 | 0.7532 | 0.7815 | 0.6242 | 1.3874 | 1.2123 |
| 20 | 1.2934 | 1.1215 | 0.7996 | 0.8021 | 0.8330 | 0.6828 | 1.2694 | 0.9271 |
| 50 | 1.1472 | 0.8638 | 0.8585 | 0.8077 | 0.8540 | 0.7109 | 1.1397 | 0.7862 |
| 80 | 1.0489 | 0.7127 | 0.8799 | 0.8111 | 0.8499 | 0.7195 | 1.0833 | 0.7827 |
| **98** | 1.0037 | 0.6599 | 0.8770 | 0.8308 | 0.8511 | 0.7201 | 1.0768 | 0.7586 |

*結果圖表參考*

：
- 綜合訓練結果：

![Results](20260714_all_models_training_metrics/yolo26n_p2_results.png)

- PR 曲線：

![PR Curve](20260714_all_models_training_metrics/yolo26n_p2_pr_curve.png)

- 混淆矩陣：
    
    ![confusion_matrix_normalized.png](20260714_all_models_training_metrics/yolo26n_p2_confusion_matrix_norm.png)
    

### 4. YOLO26-nano-p2-w8a32 詳細訓練軌跡

- **最優狀態**：微調第 7 個 Epoch 達到最優。
- **指標數值**：[mAP@50](mailto:mAP@50) = 0.8463，[mAP@50](mailto:mAP@50):95 = 0.7132，F1-Score = 0.8372。

| Epoch | Train Box Loss | Train Cls Loss | Precision | Recall | [mAP@50](mailto:mAP@50) | [mAP@50](mailto:mAP@50):95 | Val Box Loss | Val Cls Loss |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 0.9941 | 0.6366 | 0.8622 | 0.8103 | 0.8524 | 0.7159 | 1.1304 | 0.8884 |
| **7** | 0.8883 | 0.4817 | 0.8662 | 0.8101 | 0.8463 | 0.7132 | 1.1446 | 0.8940 |

*結果圖表參考*

：
- 綜合訓練結果：

![Results](20260714_all_models_training_metrics/yolo26n_p2_w8a32_results.png)

- PR 曲線：

![PR Curve](20260714_all_models_training_metrics/yolo26n_p2_w8a32_pr_curve.png)

- 混淆矩陣：

![Confusion Matrix](20260714_all_models_training_metrics/yolo26n_p2_w8a32_confusion_matrix_norm.png)

---

## 4. SSD-MobileNetV3 系列詳細數據

SSD-MobileNetV3 系列模型在兩階段訓練（Phase 1 與 Phase 2）過程中的關鍵數據如下：

### 1. SSD-MobileNetV3-large 詳細訓練軌跡

- **最優狀態**：Epoch 36 達到最優。
- **指標數值**：[mAP@50](mailto:mAP@50) = 0.4717，[mAP@50](mailto:mAP@50):95 = 0.3269。

| Epoch | Phase | Train Loss | Val Loss | [mAP@50](mailto:mAP@50) | [mAP@50](mailto:mAP@50):95 |
| --- | --- | --- | --- | --- | --- |
| 1 | 1 | 12.1682 | 13.1189 | 0.0017 | 0.0005 |
| 5 | 1 | 5.5879 | 7.7570 | 0.2264 | 0.1656 |
| 6 | 2 | 5.0583 | 7.5679 | 0.2607 | 0.1879 |
| 10 | 2 | 4.4717 | 7.1801 | 0.3530 | 0.2446 |
| 20 | 2 | 3.8704 | 6.8113 | 0.4264 | 0.3014 |
| 30 | 2 | 3.5118 | 6.7124 | 0.4582 | 0.3229 |
| **36** | 2 | 3.5202 | 6.6844 | 0.4717 | 0.3269 |
| 45 | 2 | 3.6372 | 6.6560 | 0.4693 | 0.3210 |

#### 不同置信度閾值下的評估數據（SSD-MobileNetV3-large，以 IoU 閾值 0.5 匹配）

| 置信度閾值 (Threshold) | 精確搜尋率 (Precision) | 召回檢出率 (Recall) | F1-Score |
| --- | --- | --- | --- |
| 0.01 | 0.0079 | 0.4537 | 0.0154 |
| 0.05 | 0.0270 | 0.4207 | 0.0507 |
| 0.10 | 0.0672 | 0.2907 | 0.1092 |
| 0.15 | 0.1106 | 0.1978 | 0.1419 |
| **0.20** | **0.1870** | **0.1471** | **0.1647** |
| 0.30 | 0.3885 | 0.0806 | 0.1335 |
| 0.40 | 0.5595 | 0.0621 | 0.1118 |
| 0.50 | 0.6541 | 0.0533 | 0.0986 |

*結果圖表參考*

：
- Loss 訓練對比曲線圖：

![SSD Loss Curves](20260714_all_models_training_metrics/ssd_mnv3_loss_comparison.png)

- 混淆矩陣 (Threshold = 0.20)：

![SSD Large Confusion Matrix](20260714_all_models_training_metrics/ssd_mnv3_large_confusion_matrix.png)

- PR 曲線對比圖：

![SSD PR Comparison](20260714_all_models_training_metrics/ssd_mnv3_pr_comparison.png)

### 2. SSD-MobileNetV3-small 詳細訓練軌跡

- **最優狀態**：Epoch 40 達到最優。
- **指標數值**：[mAP@50](mailto:mAP@50) = 0.4541，[mAP@50](mailto:mAP@50):95 = 0.2676。

| Epoch | Phase | Train Loss | Val Loss | [mAP@50](mailto:mAP@50) | [mAP@50](mailto:mAP@50):95 |
| --- | --- | --- | --- | --- | --- |
| 1 | 1 | 14.0265 | 14.9114 | 0.0030 | 0.0009 |
| 5 | 1 | 5.8996 | 8.6495 | 0.3417 | 0.1821 |
| 6 | 2 | 5.4972 | 8.5976 | 0.3648 | 0.1986 |
| 10 | 2 | 5.2365 | 8.4226 | 0.3836 | 0.2158 |
| 20 | 2 | 4.8347 | 8.1776 | 0.4308 | 0.2488 |
| 30 | 2 | 4.5748 | 8.1014 | 0.4525 | 0.2624 |
| **40** | 2 | 4.6190 | 8.0738 | 0.4527 | 0.2676 |
| 45 | 2 | 4.5914 | 8.0699 | 0.4492 | 0.2603 |

#### 不同置信度閾值下的評估數據（SSD-MobileNetV3-small，以 IoU 閾值 0.5 匹配）

| 置信度閾值 (Threshold) | 精確搜尋率 (Precision) | 召回檢出率 (Recall) | F1-Score |
| --- | --- | --- | --- |
| 0.01 | 0.0038 | 0.2216 | 0.0075 |
| 0.05 | 0.0153 | 0.1859 | 0.0282 |
| 0.10 | 0.0929 | 0.1269 | 0.1073 |
| 0.15 | 0.2265 | 0.0956 | 0.1344 |
| **0.20** | **0.3422** | **0.0850** | **0.1362** |
| 0.30 | 0.4492 | 0.0700 | 0.1212 |
| 0.40 | 0.5668 | 0.0617 | 0.1112 |
| 0.50 | 0.6526 | 0.0546 | 0.1008 |

*結果圖表參考*

：
- mAP 訓練對比曲線圖：

![SSD mAP Curves](20260714_all_models_training_metrics/ssd_mnv3_map_comparison.png)

- 混淆矩陣 (Threshold = 0.20)：

![SSD Small Confusion Matrix](20260714_all_models_training_metrics/ssd_mnv3_small_confusion_matrix.png)

- PR 曲線對比圖：

![SSD PR Comparison](20260714_all_models_training_metrics/ssd_mnv3_pr_comparison.png)

### 3. 混淆矩陣極端數據查證與分析

針對 SSD 系列模型在混淆矩陣中呈現的「極端分佈」（例如：`P_AP_LD` 與 `P_TP_LD` 全為 0，以及 `P_SI` 漏檢高達 1561 個），我們對 COCO 原始標註檔與推論預測分佈進行了嚴謹的學術查證，確認該矩陣**精確且客觀地反映了資料集的真實分佈及模型架構的極限**：

1. **缺失標註類別 (`P_AP_LD`, `P_TP_LD`) 為 0 的真相**：
經解析原始 JSON 檔案，上述兩類別在訓練集 (`instances_train.json`) 與驗證集 (`instances_val.json`) 中的真實標記數**皆為 0**。由於資料集缺乏這兩類樣本，模型無法學習，驗證集亦無真實框可供匹配，因此在混淆矩陣中呈現全 0 是合理的。
2. **極小目標 (`P_SI`) 漏檢高達 1561 個**：
介殼蟲 (`P_SI`) 為極其細小且密集的目標（驗證集中共有 1561 個真實標記）。SSD-MobileNetV3 受到 `320x320` 低解析度輸入的硬性限制，且缺乏如 PANet 般的高解析度淺層特徵融合網路。經過深層卷積下採樣後，微小斑點特徵幾乎完全丟失。
預測統計顯示，模型對 `P_SI` 的所有預測分數**皆低於 0.20 閾值**（通過閾值的檢出數為 0）。因此，1561 個真實目標皆無法被成功匹配，全數歸為漏檢 (False Negative)，完美暴露了 SSDLite 網路在極小目標定位上的短板。

---

---

## 5. 雙模型架構數據對比

### 1. 定位與精準度指標對比

YOLO26 系列的整體指標高於 SSD-MobileNetV3 系列。
- [**mAP@50**](mailto:mAP@50) 方面，**YOLO26-nano** 的 [mAP@50](mailto:mAP@50) 為 `0.8544`，比 **SSD-MobileNetV3-large** 的 `0.4717` 高出 38.27%，且其模型體積（5.3 MB）比後者（9.3 MB）小 43%。
- **精密定位 ([mAP@50](mailto:mAP@50):95)** 方面，YOLO26 最低為 `0.7132` (量化微調版)，而 SSD 最高僅為 `0.3269` (Large)。
- **邊界框準確率 (Accuracy)** 方面，YOLO26 模型介於 `0.7200` 至 `0.7701`，而 SSD-MobileNetV3 模型介於 `0.0731` 至 `0.0897`。該差距主要由於 SSD 的召回率（Recall）偏低，在無背景框（TN=0）的嚴格匹配計算下，公式分母中的漏檢數 (FN) 佔比力道較大，進而拉低了其 Accuracy 數值。

### 2. 參數量與模型大小對比

- **YOLO26-nano**：5.3 MB
- **SSD-MobileNetV3-small**：6.8 MB
- **SSD-MobileNetV3-large**：9.3 MB
- **YOLO26-large**：50.7 MB

### 3. 兩階段訓練與單階段訓練收斂效率

- **SSD-MobileNetV3** 在 Phase 1（1~5 Epochs）僅微調偵測頭時，Loss 從 12.16 降至 5.58。解凍骨幹（Epoch 6）後，mAP 穩步提升至最優。
- **YOLO26** 從首個 Epoch 即開始進行全網更新，收斂速度較快。例如 YOLO26-large 在 Epoch 10 即可達到 [mAP@50](mailto:mAP@50) = 0.8254。

![ssd_small_confusion_matrix.png](20260714_all_models_training_metrics/ssd_mnv3_small_confusion_matrix.png)