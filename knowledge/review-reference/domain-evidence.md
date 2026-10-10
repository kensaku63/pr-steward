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

## Typed JSON reader と履歴比較

opt-in比較へ破損処理を追加するとき、通常readerのtyped decode・legacy判定・container authorityを守る。Rust/JavaScriptの数値同値と検証範囲の扱いは [Typed JSON reads and comparison boundaries](../typed-json-read-and-comparison-boundaries.md) を必要時に参照する。

## 診断コード生成物とsource symbolの移動

- 診断コードの文字列・routingが同じでも、生成元の関数を移動・改名するとsupport inventoryのsource symbolが変わる。内部helperへの抽出も対象で、Rustの回帰成功だけではCLI/Webの生成契約一致を証明しない。
- `dev/scripts/support-contract-README.md`に従いgeneratorを実行し、CLI appendixとWeb copyの両方を照合する。symbol移動だけなら参照だけを更新し、codeやrouting・復旧手順を追加変更しない。`--check`と既存mutation suiteで確認する。
- CIのstale生成物はbase/headで同じcommandを比較して原因を分類する。base成功・head失敗なら今回の統合漏れとして修正する。upstream jobの失敗による後続SKIPPEDと、修正後のhosted CI pendingは、それぞれ未実行・実行中として記録する。

## React Query と実ブラウザーの表示証拠

- tracked propertiesを使うqueryのhook testでは、render callbackが確認対象の`data`も読むようにする。`fetchNextPage()`の返り値とcacheには次pageがあるのに`result.current`が更新されない場合、testが`isSuccess`だけを読んで通知対象を限定していないか確認する。test内でquery resultをspreadして観測する方法も使える。先にcache・返り値・購読を照合し、製品へ`notifyOnChangeProps`の変更や強制rerenderを足さない。
- fetch mockを複数回使う場合はrequestごとに新しい`Response`を返す。同じResponseの再利用によるbody consumed errorを、APIのdecode失敗と混同しない。
- ReactFlowのfitは実containerの幅と高さ、positive寸法のResizeObserver通知、初回fitとzoom下限の全node boundsで確認する。寸法計算unitやmock wrapperだけで表示成功としない。wheel/zoom testは実際のpaneへ操作を届け、callback発火だけでzoom変更を判断しない。background refetchで選択・focus・読み位置・viewport transformが保持されることも変更範囲に応じて確認する。
- accessible nameは実際にfocusされるrole button wrapperで確認する。明示`aria-label`を持つwrapperの内側へsr-only文を足しても、そのnameの状態表現は更新されない。実browserのrole/nameとEnter/Space選択を確認し、HTTP mockでのUI証拠、実DB/API証拠、SR音声の確認を区別する。commit前のbrowser結果を最終headへ使う場合は、対象component・関連入力・fixtureの同一性を照合し、挙動を変えた範囲だけ再実行する。

## Atomic file公開と独立processの競合回帰

- renameで公開するファイルはinodeが変わるため、書込排他には置換しないsidecarを使う。既存の排他dependencyと責務を再利用し、初回作成と不正内容の修復を同じlock取得後read→完成tempのatomic公開へまとめる。正常な既存値のfast pathまでlock必須へ広げるかは契約で判断し、別ownerのlockや新しいregistryへ責務を移さない。
- process間排他の回帰は独立processとisolated rootで検証する。並行開始はready signalを揃える。待機callerのrecheckは、parentが排他を保持し、callerのcritical boundary到達を非blocking lockのWouldBlockなどの同期信号で確定してから、parentが既知の完成値をatomic公開して解放する。全callerの返却値、disk、後続readの一致と、排他中に返却しないことを確認する。sleepだけの到達推定やprocess内Mutexで代用しない。
- ignored subprocess fixtureはparentからの実起動、終了code、有限timeout、失敗時のkill/waitとcleanupを確認し、top-levelのignored件数をPASSへ加算しない。旧bodyにtest-only到達信号だけを足したnegative controlで検証が退行を検出するか確認する場合は、旧挙動を変えず、保存した修正bodyを復元・照合して最終codeでfocused suiteを再実行する。negative controlの意図したFAILと環境failure、修正後PASSを別々に記録する。

## 対話 CLI の認証・承認・出力証拠

- login statusの結果には、実際に使ったHOMEとproviderの設定・認証directoryの条件を付ける。新しい空のdirectoryで未ログインでも、通常の利用環境が未ログインとは限らない。人間が現在のマシンでの検証を指定した場合は、通常環境のlogin statusを確認し、認証情報を読んだり複製したりせず、許可された既存ログインをCLI経由で使う。fixture・診断対象・cwdの隔離と、認証環境の隔離は別の条件として扱う。
- 対話動作が仕様に含まれる場合、実TUIでargv・cwd・stdin/stdout/stderrの接続、実効sandboxとapproval policy、個別承認・拒否・終了を確認する。helper unitや非対話実行だけで代替しない。修復試験はsynthetic fixtureへ限定し、機密値や悪意ある診断文もsyntheticにする。設定の上書き試験には一時的な専用profileを使い、既存設定を変更せず、試験後に自分が作ったprofileだけを削除する。
- macOSのPTY captureでは、最後のslaveを閉じてからmasterを読むと未読stdoutが失われた事例がある。子processの終了codeを先に保存し、slaveを保持したままmasterを有限timeoutでdrainしてからdescriptorを閉じる。出力が空なら同じ接続構成でecho等の最小再現を行い、capture不良と製品不良を分ける。対話中の修復証拠と、receipt JSON・終了codeの証拠はそれぞれ記録し、再試験が出力確認だけなら修復成功まで再確認したとは扱わない。
