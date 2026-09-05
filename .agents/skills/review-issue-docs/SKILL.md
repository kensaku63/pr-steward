---
name: review-issue-docs
description: レビュー課題の記録と出典を管理する。Use when recording or updating findings; separate issue documents are optional.
---

# Review Issue Docs

記録量は課題の規模に合わせる。通常は既存の PR audit に、問題・証拠・影響・対応判断・検証結果をまとめてよい。独立した議論や担当への引き継ぎが必要な課題だけ、別の issue doc にする。

schema と既存 status の意味は `$AA_AGENT_DIR/knowledge/aachat-review-doc-schema.md` を参照する。既存 doc は更新し、同じ課題の記録を増やさない。

指摘の出典と自分の検証結果を区別し、重複をまとめても出典を残す。問題が成立することは提案解法の採用を意味しない。現担当が証拠と目的から採否を決め、修正後に検証結果を記録する。別 planning Session や全 status の通過は必要ない。
