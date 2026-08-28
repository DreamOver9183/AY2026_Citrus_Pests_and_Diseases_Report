---
name: add-report
description: 新增一篇報告到報告庫時使用。涵蓋放哪一章的判斷、檔名決定、骨架模板、索引頁掛載與驗證。
---

# 新增一篇報告

## 1. 先決定放哪一章

依 [`README.md`](../../../README.md) §2 的職責界線判斷。口訣：

> 「怎麼算」進〈效能指標評估〉，「算出來多少」進〈系統測試與評估〉，「怎麼做出來的」進各建置章。

判斷不出來就問使用者，**不要新開一章**。章的數量是刻意固定的。

## 2. 決定檔名

依 [`README.md`](../../../README.md) §5.2 樣式表，模型代號取自 §5.4 名詞統一表。

| 這篇是 | 檔名長這樣 |
| --- | --- |
| 訓練報告 | `20260729_yolo26n_p2_training_report.md` |
| 基準測試 | `yolo26n_p2_fp16_benchmark.md` |
| 版本比較 | `yolo26n_p2_v2_vs_v3_comparison.md` |
| 資料集統計 | `yolo26_v2_dataset_stats.md` |
| 週期報告 | `20260729_weekly_report.md` |
| 設計／說明 | `架構設計.md`（中文 2–8 字） |

檢查：無空格、無括號、無流水號結尾、日期為 8 位含年份。

## 3. 建檔位置

```
植物病蟲害辨識 (115資工四A)/<章名>/<篇名>.md          ← 報告本體
植物病蟲害辨識 (115資工四A)/<章名>/Image/<篇名>/      ← 圖表資料夾（有圖才建）
```

不得建到第四層。編碼一律 **UTF-8 不含 BOM**。

## 4. 骨架

依 [`README.md`](../../../README.md) §3。實驗類報告用這個模板：

```markdown
# <報告全名>

> 報告日期：2026-08-27
> 評測對象：yolo26n_p2（FP16 TFLite）
> 資料來源：runs/train/exp12/results.csv、args.yaml
> 撰寫人：<姓名>

## 1. 摘要

- 結論一
- 結論二
- 結論三

| 指標 | 數值 |
| --- | --- |
| mAP50 | 0.00000 |

## 2. 方法與環境

## 3. 數據與分析

## 4. 結論與限制

本報告未涵蓋：
```

設計／說明類報告免除第 2、3 段，第 1 段（H1）、報告資訊區塊、第 4 段仍必要。

超過 400 行時，在報告資訊區塊之後加 `## 目錄`。

## 5. 標題規則

寫的時候就守住，事後改很麻煩（見 [`README.md`](../../../README.md) §4）：

- 全檔**只有一個 H1**
- 不跳級、最深 H4
- 標題不加粗 `## **標題**`、不放 emoji
- 編號用 `1.` / `1.1`，**不用**「一、二、三」
- 同層編號不得重複
- 表圖用獨立流水號 `表 3-1` / `圖 3-1`，每張圖緊接一句解讀

## 6. 圖片

放進該章 `Image/` 底下與報告同名的資料夾，檔名依 [`README.md`](../../../README.md) §5.3：

```
<對象>_<圖表類型>[_<條件>].png
```

圖表類型只能用 §5.3 字典裡的詞（`results` / `pr_curve` / `f1_curve` / `p_curve` / `r_curve` / `confusion_matrix` / `confusion_matrix_norm` / `labels` / `loss_comparison` / `map_comparison`）。

**不得**用流水號區分不同對象。

引用時用相對路徑，中文與空格 percent-encode：

```markdown
![圖 3-1 PR 曲線](Image/%E6%A8%A1%E5%9E%8B%E8%A8%93%E7%B7%B4%E6%95%B8%E6%93%9A%E5%A0%B1%E5%91%8A/yolo26n_p2_pr_curve.png)
```

## 7. 掛上索引

在該章的 L1 索引頁 `植物病蟲害辨識 (115資工四A)/<章名>.md` 加一行連結。

**章索引頁只放導覽，不要順手把正文寫進去。**

## 8. 驗證

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/verify-links.ps1
powershell -ExecutionPolicy Bypass -File .agent/scripts/audit-structure.ps1
```

新增報告會讓 `files_without_summary` 等指標上升 → audit 直接 fail。這是**設計如此**：新報告本來就該一次寫對。fail 的話回去補，不要改基準線。

最後依 [`README.md`](../../../README.md) §7 檢查清單逐項確認，再依 [`commit-and-push`](../commit-and-push/SKILL.md) 提交。
