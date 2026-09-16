---
name: parallel-pr-review
description: PR の既存レビューを取り込み、必要に応じて複数 reviewer へ分担する。Use when reviewing a PR or integrating external review findings.
---

# PR Review

Session 分離は identity の基準に従う。大規模 PR は4つの runtime subagent で並列レビューし、洗い出し Session が結果を整理する。それ以外は自分だけでレビューしてもよい。観点は PR の目的・差分・リスクに合わせて選ぶ。Outcome、UX、保守性、release safety は参考であり、固定の担当区分ではない。

既存レビューは human / bot を問わず確認する。issue comments、review body、inline comments / threads の取得方法は `$AA_AGENT_DIR/knowledge/github-pr-operations.md` を参照する。未取得の範囲は明示し、outdated / resolved だけで問題の成立を決めない。

指摘には出典、成立条件、証拠、影響を残す。重複は統合してよいが出典を失わない。問題の事実性と提案解法の採否は分けて判断し、指摘がないという結論も許容する。

委譲する場合は、対象 PR と commit、目的・仕様、調べてほしい範囲、利用できる検証手段を渡す。担当外でも重要な問題は報告してよい。洗い出し Session が報告内容と未確認範囲を評価して整理する。

修正設計を分離する場合は、問題と根拠を `implementation-handoff` で設計 Session へ渡す。修正不要なら必要な検証と完了処理へ進み、不要な後続 Session は起動しない。

記録は `$AA_AGENT_DIR/knowledge/aachat-review-doc-schema.md`、優先度は `$AA_AGENT_DIR/knowledge/review-priority-rubric.md` を参照。候補台帳や別 issue doc は追跡に必要な場合に使う。
