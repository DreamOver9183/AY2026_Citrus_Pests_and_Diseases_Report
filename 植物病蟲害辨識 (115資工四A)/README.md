# 植物病蟲害辨識 (115資工四A)

## 總覽

柑橘病蟲害端側辨識與離線 RAG 防治決策系統的研究報告主體。各章職責界線見 [`.agent/SPECIFICATION.md`](../.agent/SPECIFICATION.md) §2。

| 章節 | 內容 |
| --- | --- |
| [行動端應用程式開發](#行動端應用程式開發) | Flutter 專案結構、需求分析、UML |
| [病蟲害辨識模型](#病蟲害辨識模型) | 模型訓練數據報告、YOLO26 各版本比較、v8/v5 比較、開發週報 |
| [RAG向量資料庫](#rag向量資料庫) | 架構設計、提示詞、手機效能測試、SLM 微調與訓練資料集 |
| [系統測試與評估](#系統測試與評估) | 各模型 TFLite benchmark 報告、匯出參數與行動端延遲掃描 |
| [效能指標評估](#效能指標評估) | 影像辨識與 RAG/SLM 模組的效能指標定義 |
| [資料集分析](#資料集分析) | 資料集統計報告 |
| [參考文獻與參考資料](#參考文獻與參考資料) | 論文文獻、開源專案參考 |

## 行動端應用程式開發

App 需求、UML、Flutter 實作與整合；模型與 RAG 的內部設計不放在本章。

本專題之使用者操作介面將部屬於行動裝置上。

並且使用 Flutter 作為軟體開發框架，開發 Android 和 IOS 平台的應用程式。 

[需求分析](%E8%A1%8C%E5%8B%95%E7%AB%AF%E6%87%89%E7%94%A8%E7%A8%8B%E5%BC%8F%E9%96%8B%E7%99%BC/%E9%9C%80%E6%B1%82%E5%88%86%E6%9E%90.md)

[UML](%E8%A1%8C%E5%8B%95%E7%AB%AF%E6%87%89%E7%94%A8%E7%A8%8B%E5%BC%8F%E9%96%8B%E7%99%BC/UML.md)

[Flutter 實作與模組整合](%E8%A1%8C%E5%8B%95%E7%AB%AF%E6%87%89%E7%94%A8%E7%A8%8B%E5%BC%8F%E9%96%8B%E7%99%BC/Flutter%E5%AF%A6%E4%BD%9C%E8%88%87%E6%A8%A1%E7%B5%84%E6%95%B4%E5%90%88.md)

## 病蟲害辨識模型

偵測模型的訓練與版本比較：超參數、收斂曲線、mAP / PR / 混淆矩陣。資料集統計請見〈[資料集分析](#資料集分析)〉。

[模型訓練數據報告](%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%E6%A8%A1%E5%9E%8B/20260714_all_models_training_metrics.md)

[柑橘病蟲害 YOLO26n-P2 模型訓練成效技術報告](%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%E6%A8%A1%E5%9E%8B/20260729_yolo26n_p2_training_report.md)

[柑橘病蟲害 YOLO26n-P2 (v8) 模型訓練成效評估報告](%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%E6%A8%A1%E5%9E%8B/yolo26n_p2_v8_training_report.md)

[YOLO26 Nano P2 模型效能評測與對比報告 (v2 vs v3)](%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%E6%A8%A1%E5%9E%8B/yolo26n_p2_v2_vs_v3_comparison.md)

[v5 與 v8 訓練成效數據比較報告（YOLO26n_P2_Citrus_MuSGD_v5-2 vs YOLO26n_P2_Citrus_MuSGD_v8）](%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%E6%A8%A1%E5%9E%8B/yolo26n_p2_v5_vs_v8_comparison.md)

[柑橘病蟲害辨識階段性進度週報（2026-08-25）](%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%E6%A8%A1%E5%9E%8B/20260825_weekly_report.md)

[柑橘病蟲害辨識階段性進度週報（2026-09-07）](%E7%97%85%E8%9F%B2%E5%AE%B3%E8%BE%A8%E8%AD%98%E6%A8%A1%E5%9E%8B/20260907_weekly_report.md)

## RAG向量資料庫

為 Android 裝置打造本地優先的向量資料庫與 RAG 系統，支援樹葉病蟲害辨識的語意搜尋、知識庫建立與離線使用。

使用的技術為 SQLite + FTS5 + sqlite-vec，並且搭配本地大語言模型（Qwen 2.5 0.5B  GGUF）推理，提供使用者病蟲害防治建議。

[架構設計](RAG%E5%90%91%E9%87%8F%E8%B3%87%E6%96%99%E5%BA%AB/%E6%9E%B6%E6%A7%8B%E8%A8%AD%E8%A8%88.md)

[提示詞](RAG%E5%90%91%E9%87%8F%E8%B3%87%E6%96%99%E5%BA%AB/%E6%8F%90%E7%A4%BA%E8%A9%9E.md)

### SLM 模型微調

[使用 LLaMA-Factory 微調 Qwen2.5-0.5B 柑橘病蟲害專用模型](RAG%E5%90%91%E9%87%8F%E8%B3%87%E6%96%99%E5%BA%AB/SLM%E5%BE%AE%E8%AA%BF%E6%93%8D%E4%BD%9C%E6%89%8B%E5%86%8A.md)

[病蟲害知識訓練資料集](RAG%E5%90%91%E9%87%8F%E8%B3%87%E6%96%99%E5%BA%AB/%E7%97%85%E8%9F%B2%E5%AE%B3%E7%9F%A5%E8%AD%98%E8%A8%93%E7%B7%B4%E8%B3%87%E6%96%99%E9%9B%86.md)

[探討 SLM 生成結果指標](RAG%E5%90%91%E9%87%8F%E8%B3%87%E6%96%99%E5%BA%AB/SLM%E7%94%9F%E6%88%90%E7%B5%90%E6%9E%9C%E6%8C%87%E6%A8%99.md)

## 系統測試與評估

所有實機實測數據：TFLite benchmark、行動端 RAG/LLM 實測、RAGAs 評估。

[柑橘病蟲害 RAGAs 評估實驗報告](%E7%B3%BB%E7%B5%B1%E6%B8%AC%E8%A9%A6%E8%88%87%E8%A9%95%E4%BC%B0/citrus_rag_ragas_evaluation.md)

[YOLO26-large FP16 TFLite 行動端實機基準測試報告](%E7%B3%BB%E7%B5%B1%E6%B8%AC%E8%A9%A6%E8%88%87%E8%A9%95%E4%BC%B0/yolo26l_fp16_benchmark.md)

[YOLO26-nano FP16 TFLite 行動端實機基準測試報告](%E7%B3%BB%E7%B5%B1%E6%B8%AC%E8%A9%A6%E8%88%87%E8%A9%95%E4%BC%B0/yolo26n_fp16_benchmark.md)

[YOLO26-nano+P2 FP16 TFLite 行動端實機基準測試報告](%E7%B3%BB%E7%B5%B1%E6%B8%AC%E8%A9%A6%E8%88%87%E8%A9%95%E4%BC%B0/yolo26n_p2_fp16_benchmark.md)

[全模型 TFLite Mobile Benchmark 效能測試報告](%E7%B3%BB%E7%B5%B1%E6%B8%AC%E8%A9%A6%E8%88%87%E8%A9%95%E4%BC%B0/all_models_tflite_benchmark.md)

[YOLO26-nano-P2 匯出參數與行動端延遲全面掃描報告](%E7%B3%BB%E7%B5%B1%E6%B8%AC%E8%A9%A6%E8%88%87%E8%A9%95%E4%BC%B0/yolo26n_p2_export_params_benchmark.md)

[行動端離線 RAG 與 LLM 效能測試報告 (含 4-Threads 與 6-Threads 完整數據)](%E7%B3%BB%E7%B5%B1%E6%B8%AC%E8%A9%A6%E8%88%87%E8%A9%95%E4%BC%B0/20260729_mobile_rag_benchmark.md)

## 效能指標評估

只放效能指標的定義：名稱、公式、單位、評測方法。實測數值請見〈[系統測試與評估](#系統測試與評估)〉。

[效能指標定義與評測方法](%E6%95%88%E8%83%BD%E6%8C%87%E6%A8%99%E8%A9%95%E4%BC%B0/%E6%8C%87%E6%A8%99%E5%AE%9A%E7%BE%A9%E8%88%87%E8%A9%95%E6%B8%AC%E6%96%B9%E6%B3%95.md)

## 資料集分析

資料集本身的規模、類別分佈、train/valid/test 劃分、增廣與標註品質統計。

[Datasets_YOLO26_v2 數據集全方位統計與分析報告](%E8%B3%87%E6%96%99%E9%9B%86%E5%88%86%E6%9E%90/yolo26_v2_dataset_stats.md)

[Datasets_YOLO26_v5 資料集統計與工程規範報告](%E8%B3%87%E6%96%99%E9%9B%86%E5%88%86%E6%9E%90/yolo26_v5_dataset_stats.md)

## 參考文獻與參考資料

外部論文與開源專案參考，不放專題自身的產出。

[學術文獻回顧](%E5%8F%83%E8%80%83%E6%96%87%E7%8D%BB%E8%88%87%E5%8F%83%E8%80%83%E8%B3%87%E6%96%99/%E5%AD%B8%E8%A1%93%E6%96%87%E7%8D%BB%E5%9B%9E%E9%A1%A7.md)

[開源專案參考](%E5%8F%83%E8%80%83%E6%96%87%E7%8D%BB%E8%88%87%E5%8F%83%E8%80%83%E8%B3%87%E6%96%99/%E9%96%8B%E6%BA%90%E5%B0%88%E6%A1%88%E5%8F%83%E8%80%83.md)

[一站式平臺服務應用規劃.pdf](%E5%8F%83%E8%80%83%E6%96%87%E7%8D%BB%E8%88%87%E5%8F%83%E8%80%83%E8%B3%87%E6%96%99/%E4%B8%80%E7%AB%99%E5%BC%8F%E5%B9%B3%E8%87%BA%E6%9C%8D%E5%8B%99%E6%87%89%E7%94%A8%E8%A6%8F%E5%8A%83.pdf)

