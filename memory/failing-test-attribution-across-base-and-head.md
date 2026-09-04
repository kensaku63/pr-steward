# 失敗 test は base / reviewed HEAD / 自分の修正 / 負荷 に切り分けてから判断する

## 発生した問題（抽象化）

approved fix の実装後に full の DB-backed track を回すと、複数の test が落ちた。内訳は三種類が混ざっていた。

- 元の PR が base から壊していた test。reviewed HEAD で既に落ちていた。
- 自分の修正が既存 test の観測前提を崩したもの。reviewed HEAD では通り、修正後だけ落ちた。
- 並列負荷や壁時計 budget に依存する flake。単独実行では通り、実行ごとに落ちる test が変わる。

これを切り分けずに「自分の修正が壊した」と扱えば、正しい修正を削って patch-on-patch に入る。逆に「元からだろう」と扱えば、自分が入れた回帰を push する。approved plan が focused test しか列挙していない場合、そもそもこの三種類のどれにも気づけない。

## 再発防止（How to apply）

1. focused test だけで merge 可否を判断しない。実装後に full track を最低 1 回は回す。approved plan の verification 節は「その修正が効いたか」を見るためのもので、「PR 全体が壊れていないか」を保証しない。
2. 失敗を見つけたら、まず単独実行する。単独で通るなら共有 DB / 並列負荷 / 壁時計 budget を疑い、実行を繰り返して再現性を測る。実行ごとに落ちる test が変わるなら flake として扱い、blocker にしない。
3. 単独でも落ちるなら出自を測る。作業を WIP commit で固定してから `git switch --detach <reviewed-HEAD>` で回し、次に base commit で回す。base で通り reviewed HEAD で落ちるなら元の PR の欠陥、両方通るなら自分の修正の回帰である。stash は使わない。
4. flake と判断した test についても、test 本文が base と一致しているか、自分の差分が当該 route や test file に触れているかを確認して記録する。「落ちたが flake」とだけ書かない。
5. 出自の判定結果を audit record と PR コメントに分けて書く。元の PR 由来の失敗を自分の修正の成果に混ぜない。
