# batch query や global count で観測する test は、母集団が増えると籤引きになる

## 発生した問題（抽象化）

修正が「対象になる行の母集団」を意図どおり広げた結果、既存 test が二種類の理由で落ちた。

一つは、production の batch query に対する membership を見ていた test。その query は候補を `LIMIT 100` で切り、さらに `FOR UPDATE ... SKIP LOCKED` で他 transaction が握る行を落とす。共有 DB で数百 test が並列に走る環境では、条件を満たす行が 1002 件あるのに helper が返す候補は 2 件だった。特定の行が返るかどうかはほぼ運で、修正前に通っていたのも運である。

もう一つは、対象 table を database 全体で `COUNT(*)` して前後比較していた test。隣の test が 1 行作るだけで落ちる。

どちらも production の欠陥ではない。batch worker は `repair_attempted_at` のような印で母集団を巡回するので、1 回の window に入らないことは問題にならない。壊れているのは観測方法である。

## 再発防止（How to apply）

1. 修正が述語を緩めて母集団を広げるときは、その母集団を観測している既存 test を先に洗う。`LIMIT`、`SKIP LOCKED`、`ORDER BY` + 打ち切り、scope なしの `COUNT(*)` が観測に挟まっていたら、その assertion は母集団サイズに依存している。
2. batch の window ではなく述語そのものを観測する形に寄せる。対象 1 件について同じ述語を評価する test-only helper を置き、述語の本文は production query と共有する。共有できないなら述語を const や関数として切り出してから共有する。第二の正本を作らない。
3. global count は自分の scope に限定する。`WHERE source_session_id = $1` のような 1 語で、並列実行に対して決定的になる。
4. batch の順序や打ち切り自体を固定したい場合は、別の test（実行計画の契約など）で固定し、述語の test と混ぜない。
5. これは「失敗 test を弱める」行為ではない。観測が測っていなかったものを測るようにする変更なので、修正前後で落ちる/通ることを mutation で確認して記録する。
