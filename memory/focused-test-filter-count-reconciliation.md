# Focused test filter の期待件数は最終集合で照合する

## 発生した問題（抽象化）

handoff が、既存の filter 対象 test を1件削除し、filter外の testを2件renameして対象へ加える計画を持っていた。一方、verification の期待件数は「修正前の対象件数 + rename件数」だけで計算され、同じplanで削除する1件が差し引かれていなかった。明示されたapproved diffは一意だったが、件数だけが矛盾した。

## 再発防止（How to apply）

1. focused command の期待集合を、修正前の実測対象から作る。Rustなら修正前後に同じfilter commandを実行し、必要なら `-- --list` でtest名を列挙する。
2. 期待件数は `修正前対象 - 削除対象 - filter外へrenameした対象 + filter内へrenameした対象 + 新規対象` で最終集合から計算する。
3. handoffには件数だけでなく、追加・除外されるtest名を記録する。件数と名前が矛盾したら、明示approved changes、ユーザー価値、simplicity budgetの順で判断する。
4. approved planが新規testを要求せず、明示changesから最終集合が一意なら、誤った件数へ合わせるためのtestを追加しない。実測結果と算術差をauditへ残す。
5. 件数矛盾がbehavior、assertion、API、stateなど実装方向を変える場合だけ停止して人間判断へ回す。証拠ラベルの算術誤記だけなら、scopeを拡張せず検証可能な最終集合を採る。

## 見分け方

focused commandが期待より1件少ないとき、最初にfailureやtest欠落を疑うのではなく、同じplanでfilter対象testを削除・renameしていないかを確認する。commandがPASSしても、実行test名が中心契約を含むことを件数と別に照合する。
