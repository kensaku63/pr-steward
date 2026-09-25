# Domain evidence reference

関連する変更をレビューするときの参考。全 PR 共通の必須チェックリストではない。適用範囲と必要な証拠は現在の仕様・利用者・release 契約から判断する。

### Online migration の evidence boundary

- release risk が staged expand、validation、cleanup の transition にある場合、HEAD 適用後に fixture を作る final-schema test だけでは十分としない。migration 直前の schema に既存の正当な row を置き、実際の timestamp migration 列を境界ごとに通す upgrade test を優先する。
- deploy planner、retirement commit の ancestry、migration header は release 順の前提を証明するが、DB 内の transition behavior の証拠ではない。両者を代替関係にせず、planner gate と DB integration test の責務を分ける。
- `NOT VALID` constraint では、追加直後の `convalidated = false` と新規不正 write の拒否を同時に確認する。validation 後の既存 row 保持、legacy protection の存続、cleanup migration でだけ旧 constraint が消えることまで DB catalog と DML で観測する。
- migration SQL の文字列や private helper の呼び出し順を正本にしない。既存 integration test が同じ schema family を所有するなら、その test を upgrade contract へ直し、第二 fixture、SQL parser、test-only state model を増やさない。

## Rolling compatibility と snapshot freshness

- client / server、CLI / API のように別々に配備される契約変更では、release順を証拠として確認し、new client → old server と old client → new server の両方向をcontract testで固定する。片方向だけの互換性はrolling releaseの安全性を証明しない。
- legacy clientの不完全snapshotではdeactivateを省略してよいが、source watermarkや世代判定を迂回してはならない。stale snapshotは既存rowの復活だけでなく、削除済みの未登録rowのinsertもno-opでなければならない。
- payload budgetのため本文を省略する場合、hashやdigestが変わったrowに旧cacheを残さない。metadataだけでbudgetを超える場合も主要処理を停止させず、無効なpartial reportを送らない挙動を境界testで固定する。

## 負荷試験の処理到達と投入条件

- 関数呼出後のcounterは、有効な処理の完了を証明しない。未知ID、未登録の要求、終了済み状態などで早期returnするfixtureを除き、必要な初期登録を実経路へ通してから測定する。最終stateや実出力も確認し、軽いno-opを負荷として数えない。
- 制御応答の終点は仕様で約束した実処理の入口に置く。writerへの送信到達は、停止受信やpermission応答処理開始の代用にならない。1回だけ受理される操作は実行対象を用意し直し、無効な再送でサンプル数を増やさない。
- baseline/loadは同じbuild最適化・runtime構成で比較する。入力件数だけでなく投入遅延・実処理時刻も残し、backpressureで試験を延長した結果や、負荷終了後の制御サンプルを指定負荷の合格に含めない。timeoutや欠測を除外してp95を良く見せない。
- 診断bytesから省略済みの値を除外する場合は、残る識別skeletonと描画用コピーの実体も別に測る。診断値0だけでは保持量が小さくなった証拠にならない。
