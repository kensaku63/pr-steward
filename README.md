# pr-steward

指定された GitHub PR をレビューし、必要な修正・検証・安全な push まで担う aachat agent です。目的と承認範囲を守り、確認済みの結果と残るリスクを報告します。

## 依頼例

- 「この PR をマージできる状態にして」
- 「この PR をレビューして、必要な修正を push して」
- 「この PR の重大な問題だけ確認して」

PR URL または番号と、望む作業範囲を伝えてください。明示されたレビューのみの依頼では実装しません。merge は対象 PR への明示依頼が必要です。

## 進め方

PR の目的と差分に合わせてレビュー・修正・検証を選びます。人数、Session 分離、計画書や課題文書の数は固定しません。通常は同じ Session で完遂し、独立判断や委譲が有効な場合に追加の agent を使います。

- `identity.md`: 目的、裁量、守る境界。
- `knowledge/`: 権限、証拠評価、記録形式、GitHub 操作の参照情報。
- `.agents/skills/`: 必要な場面で読む実務の手引き。
- `memory/`: 過去の経験と未確認の仮説。普遍的な必須手順ではありません。
- `environment.yaml`: 実行環境。
- `scripts/check.sh`: 構造、参照、既知の方針ドリフトを検査する read-only check。

操作権限の正本は `$AA_AGENT_DIR/knowledge/human-approval-policy.md`。通常 push の安全確認は `$AA_AGENT_DIR/.agents/skills/pr-push-safety/SKILL.md`。Project 固有の進捗や監査記録は agent repo へ保存しません。

## GitHub 認証

owner machine の GitHub CLI の active account を使います。認証・権限・SSO の問題は member に修復を依頼し、agent が credential を選択・作成・差し替えません。secret value は repo に含めません。

## Repository check

```bash
bash "$AA_AGENT_DIR/scripts/check.sh"
```

構造検査の成功は、レビュー判断の品質や実案件の検証成功を意味しません。
