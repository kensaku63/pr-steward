---
name: pr-push-safety
description: PR head branch への push 前チェックリストと push ルールを適用し、安全に通常 push する skill。Use before any push to a PR branch, when a push fails, or when judging whether a push is allowed at all.
---

# PR Push Safety

push は安全確認をすべて満たした場合のみ行う。

## 1. push 前チェックリスト

push 前に次を必ず確認する。1 つでも満たせない場合は push しない。

- 対象 branch が指定 PR の head branch である。
- push 先 remote と branch が PR 対象である。
- `git status` で意図しない変更がない。
- full diff（`git diff @{upstream}..HEAD` など）に secret、credential、個人環境依存、不要な生成物が含まれない。
- 依頼・承認範囲を満たす差分であり、重要な実装調整の理由が記録されている。
- 必要な検証が実行済みで、結果が記録されている。
- 最終差分の merge-blocker 判定と根拠がある。reviewer の起動自体は必須ではない。
- aachat shared document に実装結果、検証結果、残リスク、最終判定が追記されている。

## 2. push ルール

- PR head branch への通常 push（非破壊・fast-forward）は、§1 チェックリストを満たせば**人間の都度確認なしで steward 裁量で実行する**。初回 push でも確認しない。
- force push は常時禁止する。人間から依頼されても PR Steward は実行しない。
- 同一 PR / 同一セッションの自動 fix-and-push は最大 3 回までとする。回数を対象 Project の audit record shared document に記録し、上限に達したら停止して人間に報告する（runaway 防止の backstop であり、push ごとの確認ではない）。
- maintainer 以外の branch への push は人間の明示承認が必要（`$AA_AGENT_DIR/knowledge/human-approval-policy.md`）。

## 3. push 失敗時

- 原因を分類する: `auth_error` / `permission_denied` / `conflict`（non-fast-forward）/ `tool_error` / `unknown`。
- 勝手に force push しない。
- non-fast-forward の場合は remote の更新内容を確認し、fast-forward で取り込めない場合は停止して人間判断へ回す。
- transient failure の自動再試行は最大 2 回まで。

## 4. push 後

- push した commit hash を audit record doc に記録する。
- レビューと必要な修正・検証が完了し、最終 push の remote / GitHub HEAD 一致を確認したら、`$AA_AGENT_DIR/knowledge/github-pr-operations.md` の「レビュー完了ラベル」に従い `pr-steward` を付ける。
- PR コメントの投稿が依頼範囲に含まれ、final push の remote / PR exact OID を確認したら `$AA_AGENT_DIR/.agents/skills/comment-pr-fixes/SKILL.md` を読み、解決した問題と修正方法を GitHub PR コメントへ投稿する。途中の push では実行しない。
- 中断・停止した場合は branch、未コミット差分、完了済み作業、未完了作業、再開手順を shared document に記録する。
