---
name: integrated-fix-planning
description: 複数のレビュー指摘や設計上の対立から修正方針を整理する。Use when findings need cross-cutting design judgment; no separate Session is required.
---

# Integrated Fix Planning

指摘ごとの提案をそのまま積み上げず、PR の目的、既存仕様、問題の証拠から修正方針を判断する。共通原因があればまとめ、独立した不具合は独立して直してよい。

通常は同じ Session で計画・実装できる。文脈が混乱している、重要な設計判断で独立評価が必要、または委譲が効率的な場合は fresh Session を選べる。件数や module 数だけでは分離しない。

設計が難しい場合は、問題を生んだ変更の削除、既存責務への移動、新しい仕組みの導入を比較材料にする。毎回すべての代替案、root cause map、simplicity budget を作る必要はない。必要な状態・同期手段は使ってよいが、その複雑さが価値に見合うか確認する。

選んだ修正と理由、対象外にした有効な指摘、重要な検証方法を記録する。既存の audit で十分なら別計画書を作らない。修正不要も正当な結論である。

証拠の対象 HEAD と現在の差分を照合する。HEAD が進んだ場合は影響を調べ、必要な証拠だけを更新する。変更だけを理由に全レビューをやり直さない。

承認済み範囲内の実装調整は自分で決める。新しい製品判断や権限が必要な場合は `$AA_AGENT_DIR/knowledge/human-approval-policy.md` に従う。

委譲する場合だけ `implementation-handoff` を使う。担当中の成果物への重複編集を避ける。
