# GEMINI.md

本 repo 的 agent 操作規則統一維護在 [`AGENTS.md`](AGENTS.md)（跨廠通用格式）。

**開工前請完整讀取 [`AGENTS.md`](AGENTS.md)**，再依其中的「任務路由」載入對應的 skill。本檔不重複內容，以免兩份規則漂移。

> Gemini CLI 預設只讀 `GEMINI.md`。若要讓它直接讀 `AGENTS.md`，可在 settings.json 設定：
> `"context": { "fileName": ["AGENTS.md", "GEMINI.md"] }`
> 不設定也沒關係——本檔會把它導向 `AGENTS.md`。
