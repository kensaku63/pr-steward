---
name: pr-push-safety
description: PR head branch への push 前チェックリストと push ルールを適用し、安全に通常 push する skill。Use before any push to a PR branch, when a push fails, or when judging whether a push is allowed at all.
---

# PR Push Safety

PR Steward workflow の Step 8。push は安全確認をすべて満たした場合のみ行う。

## 1. push 前チェックリスト

push 前に次を必ず確認する。1 つでも満たせない場合は push しない。

- 対象 branch が指定 PR の head branch である。
- push 先 remote と branch が PR 対象である。
- `git status` で意図しない変更がない。
- full diff（`git diff @{upstream}..HEAD` など）に secret、credential、個人環境依存、不要な生成物が含まれない。
- approved fix plan 外の変更がない。ある場合は理由が記録されている。
- 必要な検証が実行済みで、結果が記録されている。
- final merge-blocker review が pass している。
- aachat shared document に実装結果、検証結果、残リスク、最終判定が追記されている。

## 2. push ルール

- 通常 push のみ許可する。
- force push は既定禁止。人間が明示承認した場合だけ許可する。
- 同一 PR / 同一セッションの自動 fix-and-push は最大 3 回までとする。回数を `memory/` に記録し、上限に達したら停止して人間に報告する。
- maintainer 以外の branch への push、初回 push 権限の付与は人間の明示承認が必要（`knowledge/human-approval-policy.md`）。

## 3. push 失敗時

- 原因を分類する: `auth_error` / `permission_denied` / `conflict`（non-fast-forward）/ `tool_error` / `unknown`。
- 勝手に force push しない。
- non-fast-forward の場合は remote の更新内容を確認し、fast-forward で取り込めない場合は停止して人間判断へ回す。
- transient failure の自動再試行は最大 2 回まで。

## 4. push 後

- push した commit hash を audit record doc に記録する。
- PR 参加者が確認すべき挙動変更、残リスク、未解決事項がある場合のみ、GitHub PR コメントに簡潔に投稿する（`knowledge/github-pr-operations.md` のコメントポリシーに従う）。
- 中断・停止した場合は branch、未コミット差分、完了済み作業、未完了作業、再開手順を shared document に記録する。
