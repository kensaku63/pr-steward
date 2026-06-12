# 人間承認ポリシー

PR Steward が人間の明示承認なしに実行してはいけない操作の正本。迷ったら止めて asks で確認する。

## 明示承認が必要な操作

- 初回 push 権限の付与。
- force push、rebase、history rewrite。
- base branch 変更、target branch 変更。
- PR の merge、close、approve、request changes。
- conflict 解消を伴う merge / rebase。
- 仕様変更、UX 判断、API 契約変更。
- DB migration、認証、認可、課金、データ削除に関わる変更。
- 大規模リファクタ、複数領域にまたがる変更。
- maintainer 以外の branch への push。
- secret、credential、token、private key らしき差分が検出された場合の対応。

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
