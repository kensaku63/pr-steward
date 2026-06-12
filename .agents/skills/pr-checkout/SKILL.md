---
name: pr-checkout
description: 対象 GitHub PR を特定し、working tree を確認してから gh pr checkout で安全に checkout する skill。Use when starting work on a target PR, when the working tree state is unknown, or before any review or fix work begins.
---

# PR Checkout

PR Steward workflow の Step 1。対象 PR を特定し、安全に checkout する。

## 1. PR を特定する

対象 PR は明示された PR URL または PR number から特定する。明示されていない場合は作業を開始せず、人間に確認する。

```bash
gh pr view <number|url> --json number,title,headRepository,headRepositoryOwner,headRefName,baseRefName,author,maintainerCanModify,headRefOid,state,isDraft
```

記録する項目:

- PR number
- head repository / head branch
- base branch
- author
- maintainer permission（`maintainerCanModify`）
- current HEAD（`headRefOid`）

## 2. working tree を確認する

```bash
git status --porcelain
git branch --show-current
```

- dirty working tree がある場合、対象 PR 由来か判定できるまで変更を開始しない。
- 判定できない場合は `dirty_worktree` として停止し、現在状態と次アクションを記録して人間に確認する。
- user changes の破棄、上書き、revert は禁止。

## 3. checkout する

```bash
gh pr checkout <number>
```

checkout 後に再確認する:

```bash
git branch --show-current
git rev-parse HEAD
git status --porcelain
```

- current branch、tracking branch、base branch、PR head が `gh pr view` の結果と一致するか確認する。
- HEAD が `headRefOid` と一致しない場合は原因を確認してから進む。

## 4. 更新の取り込み

- pull は fast-forward のみ許可する: `git pull --ff-only`
- merge commit、rebase、history rewrite は自動実行しない。
- conflict が出たら自動解消せず停止する。

## 禁止事項

- 明示されていない branch への checkout / push。
- user changes の破棄、上書き、revert。
- force push、rebase、history rewrite。

## 5. 記録

checkout 結果（PR number、branch、HEAD、working tree 状態）を audit record doc に記録する。schema は `knowledge/aachat-review-doc-schema.md` を参照。

失敗時は `knowledge/github-pr-operations.md` の失敗分類（`auth_error` / `permission_denied` / `checkout_error` / `dirty_worktree` など）に従って分類し、再試行は最大 2 回までにする。
