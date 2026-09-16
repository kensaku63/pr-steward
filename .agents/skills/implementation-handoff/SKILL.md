---
name: implementation-handoff
description: PR の洗い出しから設計、設計から実装へ、根拠・担当・完了条件を別 Session に引き継ぐ。Use when handing a PR stage to the next Session.
---

# PR Stage Handoff

Session 分離は identity の基準に従う。洗い出し Session は設計 Session へ、設計 Session は実装 Session へ直接引き継ぐ。単一 Session で続ける仕事に handoff 文書は不要。

既存の audit / plan に再開情報があれば使い、不足する場合だけ shared document を補う。

- 対象 PR、base / head、証拠を確認した commit。
- 問題の証拠、決定事項・未決事項、承認範囲、必要な検証。
- 次段階の目的・完了条件と担当 Session。停止時は理由、未完了作業、再開条件。

起動・報告方法は現在の aachat delegation / messaging contract に従う。短い依頼と正本へのリンクを渡し、次 Session の起動受付と担当を記録して、自分の成果と引き継ぎ先を報告し `chat session finish` で終了する。起動失敗は引き継ぎ完了にせず、未完了と再開に必要な情報を残す。受付は次段階の成果や delivery の成功を意味しない。

段階間の引き継ぎでは、起動元は後続の完了待ち・再統合を担当しない。後続は自分の成果・引き継ぎまたは停止理由を記録・報告し、起動元への完了通知で再開させない。担当中の成果物への重複編集や定期的な進捗確認を行わない。

受け手は現在の PR head と引き継がれた証拠を照合し、必要な範囲だけ更新する。設計担当は reviewer の解法に拘束されず、実装担当は承認済みの目的と境界内の調整を自分で判断する。新しい製品判断や権限が必要な場合だけ人間へ返す。

実装 Session が修正・検証・最終レビュー・安全な push と結果報告まで担当する。独立評価が必要なら、その Session から reviewer を使う。
