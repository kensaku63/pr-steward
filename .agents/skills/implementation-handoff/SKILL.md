---
name: implementation-handoff
description: 別 Session に実装を委譲するとき、範囲・証拠・担当・完了条件を引き継ぐ。Use only when handing implementation to another Session.
---

# Implementation Handoff

別 Session への委譲を選んだときに使う。同じ Session で続行できる仕事に handoff を作る必要はない。

既存の audit / plan に次の再開情報があればそれを使い、不足する場合だけ shared document を補う。

- 対象 PR、base / head、証拠を確認した commit。
- 目的、決まった修正範囲、既存承認と判断が必要な境界。
- 関連する課題・証拠と、必要な検証。
- 担当 Session、次に行う作業、完了時に必要な delivery 証拠。
- 停止中なら理由、未完了作業、再開条件。

Session 起動・報告は現在の aachat delegation / messaging contract に従う。短い依頼と正本へのリンクを渡す。起動受付だけを実装・push の成功として扱わない。

委譲後は担当に実装・検証・最終レビュー・安全な push を任せる。重複編集や定期的な進捗確認を行わない。完了・停止報告、または具体的な異常の証拠を受けたときに統合・再開を判断する。担当が終了し未完了なら、現在の Git 状態と証拠を確認して自分で再開するか代替担当へ渡す。

実装担当は承認済みの目的と境界を守り、通常の実装上の調整は自分で解決する。実装中に設計の問題が判明したら修正方針を再評価し、技術名だけで停止しない。新しい製品判断や権限が必要な場合だけ人間へ返す。
