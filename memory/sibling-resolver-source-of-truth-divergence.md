# 並列リゾルバの source-of-truth 分裂を疑う

## 発生した問題（抽象化）

同じ概念（例: session の「name -> project」解決）を担うリゾルバが route ファミリごとに別実装で複数存在し、**判定の母集合（フィルタ条件）が食い違う**ことがある。

具体例（PR #575）: session-scoped な name->project 解決が
- read 系（inbox/unread）= `coverage ∩ name` のみ（membership/status/kind フィルタなし）
- send 系 = `visible ∩ covered`（active membership + active status + kind + coverage）

で母集合が違い、同一入力（同名 covered project が 2 件・片方 membership revoke 済み）に対し read=`AMBIGUOUS_PROJECT`(400) / send=正常 routing(200) と API 応答が割れていた。最終データ自体は read 系の後段フィルタ（`ensure_*`）で正しくなるため、**ambiguity 判定・not_found/out-of-scope 判定だけが静かにズレる**のが見つけにくい。

## 再発防止（How to apply）

1. **PR が「ある概念の解決ロジック」を 1 箇所だけ直していたら、同じ概念を解く兄弟関数を必ず grep する**（例: `resolve_*_project_id` / `*_scope` / `*_by_name` 系）。複数あれば母集合（WHERE 条件）が一致しているか SQL レベルで突き合わせる。
2. 一致していなければ「source of truth が 1 つ」に反する分裂。**判定ロジックを 1 つの純粋関数へ抽出し、両系統がそれを共有する**形に統一する（DB クエリも同一 fn 経由に寄せる）。後段に冗長な再チェックが残るなら、resolver が権威になった時点で除去（不要なラウンドトリップ削減）。
3. 「誰の membership/権限で数えるか」が系統間で同一 principal か確認する（read 系の `read_state_user` と send 系の `claims.sub` が同一かなど）。違えば統一は単純委譲では済まない。
4. 統一の回帰テストは、**分裂していた時だけ割れる入力**（上記の revoke-済み同名 covered など）で複数経路が一致することを固定する。母集合が同じでないと落ちるケースを選ぶ。

## 関連

- `[[workspace-git-state-instability]]`: 同 PR で遭遇した別系統の workspace git 不安定。
- CLAUDE.md 設計原則「source of truth が 1 つに定まっている」「部分最適ではなく全体最適」「ロジックの置き場所は影響範囲で決める（複数クライアントが使うならサーバー側で共通化）」の直接適用例。
