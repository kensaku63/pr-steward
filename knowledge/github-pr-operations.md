# GitHub PR 操作手順

PR Steward が GitHub PR を扱うときの操作手順と制約の正本。

## PR の特定と checkout

対象 PR は明示された PR URL または PR number から特定する。

必須手順:

- `gh pr view <number|url> --json number,headRepository,headRefName,baseRefName,author,maintainerCanModify,headRefOid` で PR number、head repository、head branch、base branch、author、maintainer permission、current HEAD を確認する。
- 作業前に `git status --porcelain` を確認する。
- dirty working tree がある場合、対象 PR 由来か判定できるまで変更を開始しない。
- checkout は原則 `gh pr checkout <number>` を使う。
- checkout 後に `git branch --show-current`、tracking branch、base branch、PR head を再確認する。
- pull は fast-forward のみ許可する（`git pull --ff-only`）。merge commit、rebase、history rewrite は自動実行しない。

禁止事項:

- 明示されていない branch への checkout / push。
- user changes の破棄、上書き、revert。
- force push、rebase、history rewrite。

## push ルール

push 前チェックは `.agents/skills/pr-push-safety/SKILL.md` を正本とする。

- 通常 push のみ許可する。
- force push は既定禁止。人間が明示承認した場合だけ許可する。
- 同一 PR / 同一セッションの自動 fix-and-push は最大 3 回までとする。回数は `memory/` に記録する。
- push 失敗時は原因を分類し、勝手に force push しない。

## GitHub コメントポリシー

GitHub PR コメントには、PR 参加者が読むべき結論だけを書く。投稿してよい内容は、PR 参加者の判断または次の行動を変えるものに限る。

投稿してよい内容:

- merge value gate の `reject` または `needs-human` の結論。
- 根拠、影響範囲、期待される修正方針が揃った具体的な bug、risk、regression 指摘。
- マージ可否、修正要否、仕様判断に関わる blocker。
- 人間に選択してほしい判断事項と、選択肢ごとの影響。
- 修正後に PR 参加者が確認すべき挙動変更、残リスク、未解決事項。
- テスト結果がマージ判断を左右する場合の要点と、失敗時の原因・次アクション。

投稿してはいけない内容:

- 内部思考。
- 生ログ全文。
- 未確認の推測。
- 自動生成された大量コメント。
- secret、環境情報、credential の値。
- aachat 内部の会話そのもの。

## 失敗の分類と扱い

失敗は次のカテゴリに分類する。

- `auth_error`
- `permission_denied`
- `checkout_error`
- `dirty_worktree`
- `conflict`
- `test_failure`
- `ci_failure`
- `tool_error`
- `unknown`

共通ルール:

- transient failure の自動再試行は最大 2 回まで。
- 同じ失敗が続く場合は停止し、現在状態、原因仮説、次アクションを記録する。
- conflict は原則自動解消しない。
- CI 失敗は、自分の変更起因か、既存失敗か、flaky / infra / permission / external service かを分類する。
- 不明な CI 失敗を解消するために無制限な修正 push を繰り返さない。
- 中断時は branch、未コミット差分、完了済み作業、未完了作業、再開手順を aachat shared document に記録する。
