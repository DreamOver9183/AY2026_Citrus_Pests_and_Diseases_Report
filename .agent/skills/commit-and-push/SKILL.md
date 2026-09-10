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

## 異動 Log（CHANGELOG.md）

**每個 commit 都必須在 [`CHANGELOG.md`](../../../CHANGELOG.md) 最上方新增一筆紀錄**，欄位格式見該檔案本身。這是強制步驟，不是事後補記——commit message 寫完就接著寫這筆。

流程（log 要記錄 commit hash，但 commit 前還沒有 hash，所以分成兩個 commit）：

1. 連同本次變更一起，把 `CHANGELOG.md` 的新條目也 `git add`，**commit 欄位先寫 `(待回填)`**
2. `git commit` 送出本次變更
3. 取得剛才那個 commit 的 hash：

```powershell
git rev-parse --short HEAD
```

4. 把 hash 填入該筆條目，再用**第二個 commit** 送出回填：

```powershell
git add CHANGELOG.md
git commit -m "回填 CHANGELOG commit hash"
```

5. 確認 `git log -2` 兩個 commit 都正確後才進入下一步「推送」

**不得用 `git commit --amend` 回填。** `--amend` 會產生新的 commit hash，於是寫進 CHANGELOG 的永遠是 amend 前那一個——它不在任何分支上，只靠本機 reflog 存活，`git gc` 之後就永久失聯。本 repo 曾因此讓 17 筆紀錄中的 16 筆對照失效（2026-08-30 已比對 commit subject 全數回填修復）。

### 封存門檻

CHANGELOG 只會愈長，過長會吃掉 agent 的上下文、干擾全文檢索，也讓多人同時寫入檔案開頭時容易衝突。

| 項目 | 規則 |
| --- | --- |
| 觸發 | 條目數 **> 50 筆** 或檔案 **> 50KB**，取先到者 |
| 主檔保留 | **最近 15 筆**，其餘全部搬走。不要自行斟酌「哪些還有參考價值」 |
| 封存位置 | `.agent/changelog_archive/<最舊條目日期>_<最新條目日期>_changelog.md`，日期為 `YYYYMMDD` |
| 主檔索引 | 在規則區的 `---` 分隔線上方，補一行指向該封存檔的連結 |
| 執行方式 | 手動。pre-commit hook 只在超過門檻時印一行提醒，不會自動搬、也不會擋 commit |

搬移時整段搬（含條目之間的 `---` 分隔線），不改寫任何欄位內容。封存檔的格式見 [`.agent/changelog_archive/README.md`](../../changelog_archive/README.md)。

檢查現況：

```powershell
"{0} 筆 / {1:N0} bytes" -f (Select-String -Path CHANGELOG.md -Pattern '^## 20').Count, (Get-Item CHANGELOG.md).Length
```

## 推送

```powershell
git push origin main
```

遠端：`https://github.com/OneLeaf-dx/report`（2026-09-10 由 `DreamOver9183/AY2026_Citrus_Pests_and_Diseases_Report` 轉入組織並改名，舊網址自動轉址）

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
