---
name: final-merge-blocker-review
description: 実装後の PR に「マージを止める重大問題が残っているか」だけを判定する最終レビュー skill。Use after approved fixes are implemented, before push, or when deciding whether remaining issues are blockers or acceptable follow-ups.
---

# Final Merge-Blocker Review

PR Steward workflow の Step 7。実装後の最終レビューは、改善点探しではなく「マージを止める重大問題が残っているか」の判定に限定する。

指摘があった場合は修正して、push（`pr-push-safety`）に進む。

## 1. 確認項目

- CI、lint、typecheck、test が通るか。
- 修正が PR スコープを逸脱していないか。
- 新しい回帰、例外、race、認可漏れ、データ破壊が入っていないか。
- エラー処理と境界条件が既存仕様に合っているか。
- テストが実装内容を実際に検証しているか。
- 残課題は merge blocker ではなく follow-up で許容できるか。

## 2. やらないこと

- 新しい改善提案、style 指摘、任意リファクタの追加。
- approved fix plan に含まれない課題の実装（merge blocker でない限り）。
- 失敗テストの削除・弱体化による「通す」行為。

## 3. 判定

- blocker なし: `pr-push-safety` に進む。
- blocker あり（修正可能・スコープ内・人間判断不要）: 修正して再度この確認を行う。fix-and-push の回数上限（3 回）に注意する。
- 判断不能な仕様問題が残る場合: push 前に停止して人間判断へ回す（`knowledge/human-approval-policy.md`）。

## 4. 記録

audit record doc に次を追記する。

- 実行した検証コマンドと結果（test / lint / typecheck / build）。
- 見つかった blocker と対応。
- follow-up として残した課題と、blocker ではないと判断した理由。
- 最終判定（push 可 / 停止 / 人間判断待ち）。
