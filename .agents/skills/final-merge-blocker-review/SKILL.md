---
name: final-merge-blocker-review
description: 実装後、重大な問題が残っていないか確認する。Use before delivery or when assessing remaining merge blockers.
---

# Final Merge-Blocker Review

最終差分について、目的の達成、回帰、重大な欠陥、必要な検証、残リスクを確認する。任意の改善を探し続けず、重大な問題がなければ delivery へ進む。

実装 Session が最終レビューから delivery・結果報告まで担当する。自分で確認してよい。独立評価が有効なリスクや設計判断には、その Session から reviewer を使い結果を評価する。起動元 Session に最終判定や再統合を戻さない。委譲する場合は対象 commit、diff、目的、承認範囲、検証証拠を渡し、指摘の証拠と影響を求める。

問題があれば原因と修正の比例性を評価する。自分の修正が作った不具合も承認範囲内なら直してよい。修正を重ねて複雑さが増すなら削除・再設計も検討するが、nonce、CAS、fence などの技術名で停止しない。権限や製品判断の境界は `$AA_AGENT_DIR/knowledge/human-approval-policy.md` に従う。

必要な検証は repo の runner と CI 定義から選ぶ。PR checks が検証していない重要な範囲を見落とさない。既存の同一 commit の証拠を利用し、変更・失敗・未解決の疑問がある範囲を追加検証する。

検証が進まない場合の参考:

- 環境不在という報告は、慣用的な port / env ではなく repo の正本 runner で確かめる。
- timeout は待機前の decode、fixture、早期失敗も調べる。根拠なく timeout や assertion を緩めない。
- Dialogのkeyboard testは初期autofocus先のfocusを確認してからTabで対象へ進み、対象focusをassertしてSpace/Enterを入力する。表示直後のprogrammatic focusは遅れて走るautofocusに奪われることがある。checkboxが未選択ならtrace・失敗画像・実focus先を照合し、test操作の競合を製品の不具合と混同しない。根拠なくUI guardや固定sleepを追加しない。
- touchで読む必要があるoverflow領域は、scrollTopの直接代入だけで操作可能と判定しない。ChromiumではhasTouchとCDPのInput.dispatchTouchEventで実入力を送り、描画frameを挟んだtouchMove後のscrollTop変化、通知の保持、actionのtapを確認できる。移動中の通知はlocatorのtapなどでactionabilityを待ってから座標を取得する。Sonner 2.0.7ではtoastのtouch-action:noneとpointerによるswipe処理がタイトルのscrollに干渉し、pan-yだけでは解消しない例がある。installed実装と入力を照合し、必要ならscroll内容内のpointerdown伝播を止める最小修正を検証する。エミュレーションの成功を実機touchやSafariの証拠にはしない。
- Base UI SelectのoptionへfireEvent.clickしても選択が変わらない場合は、installed implementationのhighlight条件を確認する。highlightされたoptionだけをcommitする実装では、mouseMoveで対象をhighlightしてからclickし、triggerの選択値更新をassertする。optionの存在やclick発火だけで選択成功と扱わず、製品へguardや固定sleepを足さない。
- DB regressionのfixtureは現行enum・CHECK制約・HTTP error変換に合わせる。設計文中の呼称からroleやstatus codeを推測しない。immutableなowner/identityは初回INSERTで正しく設定し、fixtureを後から移動するために保護制約を迂回しない。fixtureの準備失敗と製品の退行を分ける。
- 共通受付へ現在認可やreplay検査を移す場合は、呼出元のsource guard・Workflow・queue mutationも含めて実lock順序を確認する。facts取得がProjectをlockすると、既存のTeam→Project guardを後へ移すだけで逆順になる。receiptを先読みする場合もSELECTのrow lockを確認し、不変fieldsと既存の受付直列化が成立するなら非lock読取を検討する。先読みだけでreplay成功を確定せず、必要な現在認可はreceiptを返す前に検査する。
- DB suiteのPoolTimedOutや通知待ちtimeoutは、同時wrapperの接続競合、shared DBを横断するdispatcherとfixture別EventRouterの混在も調べる。根拠がある場合はwrapperを独立実行し、fixture間だけtest threadsを絞って再検証する。test内部のspawn・DB lock barrier・assertionは維持し、並列suiteのFAIL、独立実行のPASS、base比較を別の証拠として残す。独立実行の成功だけで製品raceや既存flakeを断定しない。
- aachatのdoctor codeなど利用者向け診断を追加・変更した場合は、workspace repoの `dev/scripts/support-contract-README.md` に従い既存routingとCLI/Webの生成契約を確認する。リンク先procedureと実際のnext_actionを照合し、generator・`--check`・mutation suiteで検証する。code登録漏れは自身の統合契約漏れとして修正し、新しいrepair routeを自動で増やさない。
- filtered test は実行された名前・件数を確認し、0件成功を検証証拠にしない。

audit に対象 commit、検証結果、未確認範囲、blocker の有無と根拠を残す。未実行は PASS ではないが、対象外の検証まで一律に blocker としない。必要な証拠が不足する場合は未完了を明示する。push は `pr-push-safety` を参照する。

修正不要でレビュー・必要な検証が完了した場合は、`$AA_AGENT_DIR/knowledge/github-pr-operations.md` の「レビュー完了ラベル」に従い `pr-steward` を付ける。修正した場合は push 後に付ける。
