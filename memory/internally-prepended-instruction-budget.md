# 内部で prepend する instruction は caller の既存入力境界を縮めない

## 発生しやすい問題

API boundary が caller text を上限内として受理した後、server が setup instruction や routing context を先頭へ付け、結合後の text を同じ上限で再検証する実装がある。このとき内部 instruction の copy を増やすだけで、caller が以前送れた入力範囲が狭くなる。

個別の instruction substring test と hosted suite が通っても、上限近くの入力を固定していなければこの回帰は見えない。caller text 単体の validation と、内部 text を含む最終 submission validation は別の境界として追う。

## Review で確認すること

1. caller input を最初に検証する場所と byte / character 上限を確認する。
2. その後に内部 instruction、separator、metadata、rendered context を結合する場所を探す。
3. 最終 text が同じ validator を通る場合、base と current head の内部 byte 数を測り、base で成功した最大 caller input を current head でも受理できるか比較する。
4. 上限縮小が PR の承認済みユーザー価値から直接必要でなければ regression candidate とする。generic `text too long` しか返らない場合は、回復不能な UX impact も分けて記録する。
5. upload や外部 side effect の後に最終 validation が起きる場合は、失敗時 cleanup と orphan recovery も release impact として確認する。

## 最小修正の選び方

- 詳細手順が canonical contract / skill にあるなら、内部 instruction はその正本を実行させる短い route に戻す。重複 copy を削ることを優先する。
- 新しい prompt channel、永続 state、caller protocol を追加する前に、base の既存 internal-byte envelope 以下へ圧縮できるか確認する。
- full public limit を caller に開放することが pre-existing scope 外なら、PR が壊した base の既存成功境界だけを復元し、別契約へ拡張しない。
- regression test は instruction の文字列だけでなく、base で成功した境界 caller input と結合後 validation の observable result を固定する。

## Evidence の扱い

`instruction.len()` の assertion だけでは copy の意味保持を証明しない。canonical route に必要な semantic marker と caller-visible boundary test の両方を確認する。一方、上限を超える pre-existing input が引き続き失敗することは、今回の修正が無関係な API 契約変更へ広がっていない証拠になる。

