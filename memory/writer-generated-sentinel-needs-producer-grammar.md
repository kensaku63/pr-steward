# 内部 sentinel の識別は producer の生成 grammar に合わせる

## 発生した問題（抽象化）

システムが自分で差し込む内部 marker / sentinel / 制御文字列を、consumer 側が **unrestricted な prefix・substring・正規表現** で識別すると、同じ形で始まるだけの正当なユーザーコンテンツを内部物として誤分類する。

producer が生成できる値は固定文言と constrained な formatter の出力に限られるのに、consumer の受理言語だけが際限なく広い。この非対称が原因で、consumer は「内部物を隠す」つもりで正規のデータを黙って捨てる。

具体例（PR #1121）: turn を保存サイズへ縮める writer が差し込む省略 marker を、完了結果 helper が `starts_with("[aachat omitted ")` だけで判定していた。marker の仕組みを説明する assistant の最終回答がこの文言で始まると、全受領面（一覧 preview / detail / CLI）でその回答が消え、古い途中経過か空が「最終成果」として出た。失敗は deterministic で、データ側は正しいのに derived projection だけが静かに壊れる。

## 見分け方

- consumer が「内部が作ったもの」を、**渡された値の中身だけ**から判定している。
- その判定条件（prefix / 部分一致 / 緩い正規表現）が、producer の生成規則より広い。
- 「この文字列で始まる本文をユーザーが書けるか」を問うと yes になる。
- producer と consumer が同じ文言リテラルを**別々に**持っている（片方の変更でずれる）。

## 再発防止（How to apply）

1. producer の生成箇所を全て列挙し、生成しうる値の集合（固定文言 N 種 + formatter の引数空間）を書き出す。列挙できないなら、それ自体が設計の問題。
2. consumer の受理言語を、その集合と**一致**させる。固定文言は完全一致、可変部は接頭辞・接尾辞・許可要素・順序・重複まで含めた完全形で照合する。「広めに取って安全側」は逆で、正規データを捨てる側に倒れる。
3. 文言リテラルと formatter を **shared owner 1 箇所**へ置き、producer と consumer の両方がそこから参照する。二重管理を残すと必ず drift する。
4. 永続 metadata や provenance field の追加は最後の手段にする。既存の生成 grammar を共有するだけで十分な解決状態を満たせるなら、storage / wire shape を広げない。
5. 回帰テストは 2 方向で固定する。**(a)** producer が生成しうる全 marker 形が除外されること（過度に狭めていない）、**(b)** 同じ接頭辞を持つが生成形式ではない正当な値が保持されること（過度に広くない）。(b) だけ、または (a) だけでは片側の退行を検知できない。
6. 判定を狭めた PR では、述語を旧実装へ戻す control 実行を行い、新 test が実際に FAILED になることを確認する。落ちない test は欠陥を判別していない。

## 関連

- `[[canonical-root-document-reference-parity]]`: producer の正しさと consumer の受理可能性を別々に確認する、同系統の境界。
- CLAUDE.md 設計原則「source of truth が1つに定まっている」「フォールバックや互換性を作らない」の直接適用例。
