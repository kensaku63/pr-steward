# レビュー記録

Project 固有の判断・証拠・進捗は shared document に置く。通常は既存の PR audit を更新し、課題・計画・実装結果を一つにまとめてよい。個別文書と件数台帳は独立した議論、委譲、多数の指摘の追跡に役立つ場合に使う。

## Audit

推奨 path: `aachat/projects/<team>/<project>/docs/pr-steward-audit/<pr-number>-<session-id>.md`

次の情報を作業規模に応じて簡潔に残す。固定の見出しや空欄の埋め合わせは不要。

- 対象 PR、base / head、確認した commit と作業後の commit。
- 目的、主要な指摘の出典・証拠・対応判断、未確認の review surface。
- 修正と理由、承認が必要だった判断の所在。
- 検証の command・対象・結果、残リスク、最終判定。
- push 結果と remote / GitHub OID、delivery receipt の結果を区別した記録。
- 未完了なら担当、残作業、再開条件。引き継ぎ受付は delivery の証拠ではない。

GitHub 指摘は URL / ID で出典を残す。重複は統合してよい。全投稿に candidate ID を振る必要はないが、確認対象の指摘を失わない。

## 独立した issue doc が必要な場合

推奨 path: `aachat/projects/<team>/<project>/docs/review-issues/<pr-number>-<reviewer>-<slug>.md`

現在の aachat docs contract に従う。既存文書との互換のため、以下の metadata を利用できる。

```yaml
---
title: "課題のタイトル"
summary: "影響の要約"
status: proposed
pr_number: 0
reviewer_role: code_quality
severity: medium
priority: p2
confidence: medium
category: code-quality
merge_blocker: false
related: []
sources: []
---
```

本文には問題の成立条件・証拠・影響と十分な解決状態を示す。解法を書く場合は検証した事実と分ける。判断や検証の進展を同じ文書へ追記する。

既存 status の意味:

- `proposed`: 検討対象の課題。
- `accepted`: 修正対象として採用。
- `rejected`: 問題が成立しない、または修正価値がない。
- `deferred`: 今回の範囲外、follow-up、または人間判断待ち。
- `superseded`: 後続変更や別修正で独立対応が不要。
- `duplicate`: 他課題へ統合。`duplicate_of` に参照を残す。
- `fixed`: 修正と必要な検証が完了。

全 status の通過や別 Session による更新は不要。古い audit の分類や件数は歴史的記録として保持する。

## 委譲

必要な場合だけ `$AA_AGENT_DIR/.agents/skills/implementation-handoff/SKILL.md` を参照する。既存 audit / plan に再開に十分な情報があれば別文書を増やさない。
