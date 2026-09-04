# 人間承認ポリシー

PR Steward の操作権限の正本。迷ったら止めて asks で確認する。他の文書や skill はこの分類を再定義せず参照する。

## 操作権限の判断表

| 分類 | 操作 | 扱い |
| --- | --- | --- |
| Steward 裁量 | 指定 PR head branch への検証済み通常 push | `pr-push-safety` を満たせば都度確認なしで実行 |
| 明示承認が必要 | base / target branch 変更、merge、close、approve、request changes、仕様・UX・API・DB・認証・認可・課金・データ削除、大規模変更、maintainer 以外の branch への push | 対象と操作が明示されるまで停止 |
| merge 依頼に含まれる | 指定 PR を最新 base へ通常 mergeすること、そのための最小限の conflict 解消、検証後の通常 merge | 下記の限定条件を満たす場合だけ追加 Ask なしで実行 |
| 常時禁止 | force push、rebase、history rewrite、user changes の破棄・上書き | 人間から依頼されても PR Steward は実行しない |
| 即時停止 | secret、credential、token、private key らしき差分 | 値を表示・保存・公開コメントせず `needs-human` として人間判断へ回す |

## push は確認不要で進める（既定）

PR head branch への**通常 push（非破壊・fast-forward）は人間の都度確認を取らずに steward 裁量で進める**。初回 push であっても確認は不要。

ただし安全は人間確認ではなく `pr-push-safety` skill のチェックリスト（branch 一致 / secret スキャン / fast-forward / 検証 green / final merge-blocker review pass / 監査記録）で担保する。チェックリストを 1 つでも満たせない場合や、下記「明示承認が必要な操作」に該当する push は引き続き停止して asks で確認する。

## 明示承認が必要な操作

- base branch 変更、target branch 変更。
- PR の merge、close、approve、request changes。
- conflict 解消を伴う merge。ただし、下記「PR merge 依頼に含まれる承認」の範囲を除く。
- 仕様変更、UX 判断、API 契約変更。
- DB migration、認証、認可、課金、データ削除に関わる変更。
- 大規模リファクタ、複数領域にまたがる変更。
- maintainer 以外の branch への push。
- secret、credential、token、private key らしき差分が検出された場合の対応。

secret 検出は merge value の `reject` ではない。公開 PR コメントへ詳細を書かず、検出箇所と値を伏せたまま Project Ask で対応判断を求める。

## PR merge 依頼に含まれる承認

人間が対象 PR を指定して「マージして」と明示依頼した場合、その PR を最新 base へ通常 mergeし、マージに必要な conflict を解消して PR head branch へ通常 pushし、検証後に PR を mergeするところまで承認済みとして扱う。conflict があるという理由だけで追加 Ask は作らない。

この承認で許可されるのは、両側の互換な意図を保持する最小限の conflict 解消である。解消後は対象テスト、必要な full gate、fresh merge-blocker review、`pr-push-safety`、hosted checksを再実行する。PR head への push は通常 fast-forward、PR の merge は repo の通常方式を使う。

次の場合は merge 依頼に含めず、引き続き人間判断へ回す。

- どちらかの仕様やユーザー挙動を捨てる必要があり、正解がコード・テスト・正本から決まらない。
- API契約、DB migration、認証、認可、課金、データ削除、secret対応など、別の明示承認事項に踏み込む。
- conflict 解消がPR目的外の大規模変更へ広がる。
- rebase、force push、history rewrite、base branch / target branch変更が必要になる。
- remote head が進み、通常 fast-forward push では届けられない。

## 承認済みの受け入れ済み副作用

PR 本文が「この挙動は承認済み SPEC で受け入れている」と述べる場合、それは authority の主張であり、planning は採否を決める前に検証する。検証結果で disposition が変わる。

検証する 3 点を分けて確認し、確認できなかったものは `未確認` と明記する。

- 正本 SPEC 本文に、reviewer が指摘した挙動そのものが書かれ、受け入れると宣言されているか。
- SPEC の変更境界が、その修正対象 surface を対象外と宣言しているか。対象外なら修正は scope 拡張であり、未完了の埋め合わせではない。
- 承認の所在。authority は回答済みの人間の決定にあり、SPEC の `status` field ではない（実装承認後も `draft` のまま残ることがある）。その決定が当該副作用を判断点として enumerate していたかを確認する。

PR の変更 file が SPEC の実装構成と一致することも確認する。一致は PR が承認境界の内側に留まった強い証拠になる。

主張が成立する場合、その指摘は `accepted` ではなく `deferred` にする。症状が evidence-validated でも、解法は仕様を所有する Project のものである。人間が明示的に受け入れた副作用を再び開くのは仕様・UX 判断なので、steward 裁量ではなくその Project の承認経路へ回す。merge blocker として扱わない。

doc / contract 修正の scope 判定では、訂正と新規追加を分ける。PR が既存の記述を誤りにしたなら訂正は scope 内。contract がその領域に元々触れていないなら追記は新規追加であり、同じ scope 判断を受ける。exact head で contract 本文を読んでから判定し、stale だと推測しない。

design change 0 件の approved plan は正当な planning 結果である。保存則を記録し、implementation handoff を起動せず報告する。

## `needs-human` に倒す条件

merge value gate やレビュー精査で次に該当する場合、自動で進めず人間判断へ回す。

- 価値判断に必要な文脈が不足している。
- プロダクト判断、公開範囲、事業判断が必要。
- 破壊的変更の許可が必要。
- 自動 reject には証拠が弱い。
- ブランド、コピー方針、情報設計、ユーザー調査、A/B テストが必要な UX 判断。
- approved fix plan が誤り、不完全、危険と判明した。
- 最終レビューで判断不能な仕様問題が残った（push 前に停止する）。

## asks の書き方

- 人間に選択してほしい判断事項と、選択肢ごとの影響を簡潔に書く。
- 判断材料の長文は shared document に置き、asks には結論と doc link だけを書く。
- 作者の意図・能力への評価、証拠のない推測、secret の値そのものは書かない。
