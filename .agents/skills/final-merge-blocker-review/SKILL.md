---
name: final-merge-blocker-review
description: 実装後の PR に「マージを止める重大問題が残っているか」だけを判定する最終レビュー skill。Use after approved fixes are implemented, before push, or when deciding whether remaining issues are blockers or acceptable follow-ups.
---

# Final Merge-Blocker Review

PR Steward workflow の Step 7。実装後の最終レビューは、改善点探しではなく「マージを止める重大問題が残っているか」の判定に限定する。

このレビューは **新規 session を起動せず、実装を行った session の中からサブエージェント（Agent tool）として実行する**。実装の文脈に引きずられない fresh context のレビュアーを 1 つ起動し、その判定を親（実装 session）が精査する。

指摘があった場合は親が修正して、push（`pr-push-safety`）に進む。

## 1. サブエージェントの起動

実装 session が、merge-blocker 判定専用のレビューサブエージェントを 1 つ起動する。プロンプトには次を含める。

- PR number / base branch / head branch と、判定対象の diff 範囲（`git diff <base>...HEAD`）。
- approved fix plan doc と関連 review issue docs への参照。
- 下記「確認項目」「やらないこと」をそのまま制約として渡す。
- 出力形式: blocker の有無、blocker ごとの証拠（file:line）と影響、follow-up 扱いにした課題とその理由。

サブエージェントには判定だけをさせる。修正の実装、push、session 起動はさせない。

## 2. 確認項目（サブエージェントに渡す）

- CI、lint、typecheck、test が通るか。
- 修正が PR スコープを逸脱していないか。
- 新しい回帰、例外、race、認可漏れ、データ破壊が入っていないか。
- エラー処理と境界条件が既存仕様に合っているか。
- テストが実装内容を実際に検証しているか。
- 残課題は merge blocker ではなく follow-up で許容できるか。

## 3. やらないこと（サブエージェントに渡す）

- 新しい改善提案、style 指摘、任意リファクタの追加。
- approved fix plan に含まれない課題の実装（merge blocker でない限り）。
- 失敗テストの削除・弱体化による「通す」行為。

## 4. 判定

親（実装 session）はサブエージェントの指摘を鵜呑みにせず、証拠を自分で確認してから判定する。

- blocker なし: `pr-push-safety` に進む。
- blocker あり（修正可能・スコープ内・人間判断不要）: 親が修正し、再度サブエージェントでこの確認を行う。fix-and-push の回数上限（3 回）に注意する。
- 判断不能な仕様問題が残る場合: push 前に停止して人間判断へ回す（`knowledge/human-approval-policy.md`）。

## 5. 記録

audit record doc に次を追記する。

- 実行した検証コマンドと結果（test / lint / typecheck / build）。
- 見つかった blocker と対応。
- follow-up として残した課題と、blocker ではないと判断した理由。
- 最終判定（push 可 / 停止 / 人間判断待ち）。
