---
name: comment-pr-fixes
description: 修正実装と最終検証が完了し、PR head branch への最終 push が成功した直後、または PR を新規作成した直後に、解決した問題と修正方法を GitHub PR コメントへ簡潔に投稿する skill。Use only at final PR delivery; do not use during planning, review, implementation, validation, or intermediate pushes.
---

# Comment PR Fixes

PR 参加者が、何が問題で、最終的にどう直ったかを差分調査なしで判断できるコメントを 1 件投稿する。

## Preconditions

次をすべて満たしてから実行する。

- 修正実装と必要な検証が完了している。
- final merge-blocker review が pass している。
- PR head branch への最終 push が成功した、または PR 作成が成功している。
- local HEAD、remote branch、GitHub `headRefOid` の exact OID が一致している。
- 対象 PR と投稿権限を確認できている。

途中の実装、review、検証、commit、push では本文を読んだりコメント案を蓄積したりしない。

## 1. 最終状態から事実を再構成する

投稿時点で次を読み直す。

- steward の修正前 OID から final OID までの commit と full diff。
- evidence-validated な review issue と approved fix plan。
- 実行済み検証の command、結果、未実施項目。
- final merge-blocker review の判定と残リスク。

session transcript や記憶だけに依存しない。変更ファイルの列挙ではなく、利用者または運用に現れる問題と、その原因を解消した修正の対応関係を抽出する。推測、内部思考、aachat 内部状態、secret、credential、local absolute path は含めない。

## 2. コメントを書く

次の短い構造を使う。

```markdown
## 修正内容

- **問題:** <観測された不具合・リスクと影響>
  - **修正:** <どの責務・不変条件へ戻し、何を変更したか>

## 検証

- `<command または check 名>`: PASS

## 残件

- なし

<!-- pr-steward-fix-summary:<final-oid> -->
```

- 問題が複数あれば、root cause または利用者影響が異なる単位だけを追加する。
- reviewer の proposed remedy ではなく、final code に実装された解法を書く。
- test の skipped、pending、timeout、flake、browser-unavailable、permission failure、`UNMEASURED` を PASS と書かない。
- 残件がある場合は、PR 参加者の merge 判断または次の行動を変えるものだけを書く。
- 長い根拠、ログ、監査記録を貼らない。

## 3. 重複を確認して投稿する

対象 PR の conversation comments を取得し、final OID の marker が既に存在すれば再投稿しない。存在しなければ、shell 展開事故を避けるため本文を一時 body file に置き、次を実行する。

```bash
gh pr comment <pr-number-or-url> --body-file <comment-body-file>
```

投稿後に取得し直し、marker、投稿者、本文、URL を確認する。成功した comment URL と final OID を Project audit record に記録する。

## Failure handling

- comment 投稿失敗を push 失敗として扱わず、成功済み push や PR 作成を再実行しない。
- transient な comment failure は最大 2 回まで再試行する。
- auth / permission / tool failure が残れば `attention_required` として、push 成功、未投稿、原因分類、再開手順を分けて報告する。
