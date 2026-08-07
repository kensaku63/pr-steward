---
name: implementation-handoff
description: 承認済み実装計画を新しい実装セッションへ handoff し、実装制約と参照 doc を伝える skill。Use when the approved fix plan is ready, when starting a fresh implementation session, or when constraining what an implementation session may change.
---

# Implementation Handoff

PR Steward workflow の Step 7。親エージェントは、承認済み実装計画を新しいセッションへ渡す。

## 1. handoff doc を作る

handoff は aachat shared document に保存し、message には短い指示と doc link のみを書く。

推奨 path:

```text
aachat/projects/<team>/<project>/docs/pr-steward-handoff/<pr-number>-fix-plan.md
```

必須項目:

- PR URL / PR number
- 作成された shared document links（review issue docs、audit record doc）

加えて、次を含めることを推奨する:

- base branch / head branch / 作業時の HEAD
- approved fix plan（採用課題、優先度、実装順序）
- 修正ごとの変更箇所、期待挙動、検証方法
- 実行すべき lint / typecheck / test / build コマンド
- 実装セッションへの制約（次節をそのまま記載する）

## 2. 実装セッションへの制約

handoff doc に次の制約を明記し、実装セッションに遵守させる。

- approved fix plan に含まれる修正だけを実装する。
- 指摘を解決するために必要な最小限の周辺変更は許可する。
- repo の既存パターンに沿ったテスト追加・更新は許可する。
- PR 目的と無関係なリファクタは禁止する。
- 仕様、UX、API 契約を独断で変えない。
- secret、credential、`.env`、秘密鍵、token を追加・変更しない。
- 失敗テストを削除・弱体化して通さない。
- approved plan が誤り、不完全、危険、人間判断が必要と判明したら停止して報告する。

## 3. 新しい実装セッションを起動する

handoff doc を作成したら、同じ PR Steward agent の fresh session を起動して実装を任せる。既存 running session へ追加指示せず、独立した実装作業として新規 session を使う。

これは session 内側の agent コマンドなので、outside 用の `aachat` CLI ではなく `chat` を使う。

```bash
chat session run --agent <agent> --project <project> --stdin <<'EOF'
Step 7 の実装セッションです。
[[aachat/projects/<team>/<project>/docs/pr-steward-handoff/<pr-number>-fix-plan.md]] を読んで、approved fix plan の範囲だけを実装してください。
実装後は `final-merge-blocker-review` をサブエージェントで実行し（新規 session を起動しない）、blocker なしなら `pr-push-safety` に従って push まで進めてください。
完了・停止・人間判断が必要な場合は project に報告してください。
EOF
```

message には長い計画を書かない。次の内容だけを含める。

- Step 7 の実装セッションであること。
- handoff doc への wiki link（例: `[[aachat/projects/<team>/<project>/docs/pr-steward-handoff/<pr-number>-fix-plan.md]]`）。
- approved fix plan の範囲だけを実装すること。
- 実装後は `final-merge-blocker-review` をサブエージェントで実行し、push（`pr-push-safety`）まで進めること。
- 完了・停止・人間判断が必要な場合は project に報告すること。

実装セッションを起動できたら、この親セッションは以後の実装を続けない。今回の handoff で得た再利用可能な学びを `$AA_AGENT_DIR/memory/` に保存し、保存後に現在の session を終了する。

```bash
chat session finish
```

## 4. 実装セッションの必須行動（Step 7）

実装セッションは、approved fix plan を順番に実装する。

- 作業前に current branch と working tree を確認する。
- 変更は最小限に保つ。
- 既存パターン、既存 helper、repo のテスト方針を優先する。
- 修正ごとに関連する review issue doc を更新する（`review-issue-docs` skill 参照）。
- 必要な lint、typecheck、test、build を実行する。
- 実行できない検証は理由を記録する。
- 実装と検証が終わったら、`final-merge-blocker-review` skill に従い、最終レビューを **同じ session 内のサブエージェント** として実行する。最終レビューのために新規 session を起動しない。
- blocker なしと判定したら `pr-push-safety` に進む。

## 5. handoff 後の親エージェント

- Step 8（`final-merge-blocker-review`、サブエージェント実行）と Step 9（`pr-push-safety`）は実装セッションが続けて行う。親が別のレビューセッションを起動しない。
- 実装セッションが停止・報告してきた場合は、計画を修正するか人間判断へ回す。
