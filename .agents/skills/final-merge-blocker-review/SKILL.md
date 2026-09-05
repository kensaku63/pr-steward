---
name: final-merge-blocker-review
description: 実装後、重大な問題が残っていないか確認する。Use before delivery or when assessing remaining merge blockers.
---

# Final Merge-Blocker Review

最終差分について、目的の達成、回帰、重大な欠陥、必要な検証、残リスクを確認する。任意の改善を探し続けず、重大な問題がなければ delivery へ進む。

自分で確認してよい。独立評価が有効なリスクや設計判断には reviewer を使う。委譲する場合は対象 commit、diff、目的、承認範囲、検証証拠を渡し、指摘の証拠と影響を求める。

問題があれば原因と修正の比例性を評価する。自分の修正が作った不具合も承認範囲内なら直してよい。修正を重ねて複雑さが増すなら削除・再設計も検討するが、nonce、CAS、fence などの技術名で停止しない。権限や製品判断の境界は `$AA_AGENT_DIR/knowledge/human-approval-policy.md` に従う。

必要な検証は repo の runner と CI 定義から選ぶ。PR checks が検証していない重要な範囲を見落とさない。既存の同一 commit の証拠を利用し、変更・失敗・未解決の疑問がある範囲を追加検証する。

検証が進まない場合の参考:

- 環境不在という報告は、慣用的な port / env ではなく repo の正本 runner で確かめる。
- timeout は待機前の decode、fixture、早期失敗も調べる。根拠なく timeout や assertion を緩めない。
- filtered test は実行された名前・件数を確認し、0件成功を検証証拠にしない。

audit に対象 commit、検証結果、未確認範囲、blocker の有無と根拠を残す。未実行は PASS ではないが、対象外の検証まで一律に blocker としない。必要な証拠が不足する場合は未完了を明示する。push は `pr-push-safety` を参照する。
