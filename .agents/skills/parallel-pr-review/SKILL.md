---
name: parallel-pr-review
description: PR の既存レビューを取り込み、必要に応じて複数 reviewer へ分担する。Use when reviewing a PR or integrating external review findings.
---

# PR Review

PR の目的・差分・リスクに合わせて観点と分担を選ぶ。Outcome、UX、保守性、release safety は参考観点であり、4人の起動や担当領域による報告制限はない。自分だけでレビューしてもよい。

既存レビューは human / bot を問わず確認する。issue comments、review body、inline comments / threads の取得方法は `$AA_AGENT_DIR/knowledge/github-pr-operations.md` を参照する。未取得の範囲は明示し、outdated / resolved だけで問題の成立を決めない。

指摘には出典、成立条件、証拠、影響を残す。重複は統合してよいが出典を失わない。問題の事実性と提案解法の採否は分けて判断し、指摘がないという結論も許容する。

委譲する場合は、対象 PR と commit、目的・仕様、調べてほしい範囲、利用できる検証手段を渡す。担当外でも重要な問題は報告してよい。親は報告内容と未確認範囲を評価して統合する。

記録は `$AA_AGENT_DIR/knowledge/aachat-review-doc-schema.md`、優先度は `$AA_AGENT_DIR/knowledge/review-priority-rubric.md` を参照。候補台帳や別 issue doc は追跡に必要な場合に使う。
