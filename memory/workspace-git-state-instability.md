# workspace の git 状態は commit 前に必ず検証する

## 発生した問題（抽象化）

steward の作業 workspace（`.run/workspaces/...`、bare cache repo の linked worktree）で、作業中にローカルの head branch ref が一時的に **unborn 化** することがある。症状:

- `git rev-parse HEAD` が `unknown revision` で失敗。
- `git log` が「branch does not have any commits yet」。
- `git status --porcelain` が **全ファイル（数千件）を `A`（新規追加 staged）** として表示する（index が空 tree 基準になる）。
- それでも `git symbolic-ref HEAD` は head branch を指し、working tree の編集内容は残っている。

この状態で素の `git commit` を打つと、**意図した 1 ファイルではなく workspace 全ファイルを 1 commit に巻き込み、PR を破壊する**。

## 再発防止（How to apply）

1. **commit 直前に必ず `git status --porcelain` を確認**し、想定したファイルだけが出ているか目視する。`git add -A` や引数なし `git commit -a` を使わず、対象ファイルを明示 stage する。
2. head が壊れていたら、**`origin/<head-branch>` が復旧アンカー**になる（PR head commit が健在なことが多い）。`git rev-parse origin/<head>` で確認 -> 編集中ファイルを `/tmp` にバックアップ -> `git reset --mixed <pr-head-sha>`（working tree 不変・index と branch ref を PR head へ戻す）-> 再度 `git status` で対象 1 ファイルのみを確認してから stage & commit。
3. `git reset --hard` は編集を破棄するので使わない。`--mixed`（既定）は working tree を触らない。

## 関連

- 既知の host mirror writeback race（別症状: ファイル内容が revert される TOCTOU）とは別物だが、いずれも「workspace の git は外部同期で不安定になりうる」前提で、commit/push 前に ground truth を必ず取り直すこと。
