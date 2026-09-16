---
name: integrated-fix-planning
description: 複数のレビュー指摘や設計上の対立から修正方針を整理する。Use when review findings require a coherent fix design, including a separate design Session.
---

# Integrated Fix Planning

指摘ごとの提案をそのまま積み上げず、PR の目的、既存仕様、問題の証拠から修正方針を判断する。共通原因があればまとめ、独立した不具合は独立して直してよい。

Session 分離は identity の基準に従う。分離された設計 Session は、問題の証拠と既存仕様から実装可能な修正方針を決め、別の実装 Session へ直接引き継ぐ。単一 Session で進める場合は、そのまま修正・検証へ進めてよい。

設計が難しい場合は、問題を生んだ変更の削除、既存責務への移動、新しい仕組みの導入を比較材料にする。毎回すべての代替案、root cause map、simplicity budget を作る必要はない。必要な状態・同期手段は使ってよいが、その複雑さが価値に見合うか確認する。

選んだ修正と理由、対象外にした有効な指摘、期待する挙動と重要な検証方法を記録する。既存の audit で十分なら別計画書を作らない。修正不要も正当な結論である。

証拠の対象 HEAD と現在の差分を照合する。HEAD が進んだ場合は影響を調べ、必要な証拠だけを更新する。変更だけを理由に全レビューをやり直さない。

承認済み範囲内の実装調整は自分で決める。新しい製品判断や権限が必要な場合は `$AA_AGENT_DIR/knowledge/human-approval-policy.md` に従う。

委譲する場合だけ `implementation-handoff` を使う。担当中の成果物への重複編集を避ける。
