---
name: commit-and-push
description: 提交與推送時使用。定義 commit 前的強制關卡、commit message 格式、以及禁止的 git 操作。
---

# 提交與推送

## 強制關卡

**兩支腳本都通過才能 commit。沒有例外，不得以「我檢查過了」代替執行。**

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/verify-links.ps1
powershell -ExecutionPolicy Bypass -File .agent/scripts/audit-structure.ps1
```

| 腳本 | 通過條件 | 沒過怎麼辦 |
| --- | --- | --- |
| `verify-links.ps1` | 斷鏈 = 0 | 幾乎必然是改名沒同步改連結。回 [`rename-files`](../rename-files/SKILL.md) |
| `audit-structure.ps1` | 沒有任何指標上升 | 用 `-Verbose` 找出新增的違規並修掉 |

**不得**為了讓 audit 通過而執行 `-UpdateBaseline`。基準線只在指標**下降**後收緊，不是用來吸收劣化的。

## 提交前確認範圍

```powershell
git status --short
git diff --stat
```

逐項對照本次任務範圍，特別確認：

- 沒有動到不該動的報告正文（紅線 R1）
- `參考文獻與參考資料/` 下的第三方論文 PDF 沒有進入索引（紅線 R3）。索引中**只應該有** `一站式平臺服務應用規劃.pdf` 這一個 PDF：

```powershell
git diff --cached --name-only | Select-String '\.pdf$'
```

- 改名有走 `git mv`（`git status` 應顯示 `R`，不是一組 `D` + `??`）

## Commit message

正體中文，第一行 50 字內講清楚做了什麼，空行後列變更點。

```
整理病蟲害辨識模型的圖檔命名

- 依模型代號重新命名 17 張流水號圖檔（results 1/2/3 -> yolo26n / yolo26n_p2 / yolo26n_p2_w8a32）
- 同步改寫 4 個 md 內共 31 條圖片連結
- audit: image_serial_suffix 17 -> 0，基準線已收緊
```

- 描述**做了什麼與為什麼**，不要只寫「更新檔案」
- 涉及 audit 指標變化時，把數字寫進 message，之後回溯很有用
- 不要把 `.agent/baseline.json` 的更新拆成獨立 commit，跟造成變化的那次變更放一起

## 推送

```powershell
git push origin main
```

遠端：`https://github.com/DreamOver9183/AY2026_Citrus_Pests_and_Diseases_Report`

**推送前必須取得使用者確認。** 這是團隊共用的公開 repo，推上去等於發佈。

## 禁止的操作（紅線 R2）

| 禁止 | 理由 |
| --- | --- |
| `git push --force` / `--force-with-lease` | 團隊共用，會蓋掉別人的工作 |
| `git rebase` 已推送的 commit | 同上 |
| `git commit --amend` 已推送的 commit | 同上 |
| `git reset --hard` 到已推送之前 | 同上 |
| `git checkout -- .` 在未確認工作區內容時 | 會靜默丟掉未提交的變更。丟棄前先 `git status` 看清楚 |

需要撤銷已推送的變更時，用 `git revert` 產生新 commit，不要改寫歷史。

## 推送後驗證

改名或改連結的變更，**務必實際開 GitHub 確認渲染**——中文路徑與 percent-encoding 的問題只有在 GitHub 上才看得出來。

檢查：README 的章節連結可點、隨機開一篇含圖的報告確認圖片載入正常。
