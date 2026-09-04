# サブエージェントの「環境が無いので未実行」は親が repo の正本 runner で再確認する

## 発生した問題（抽象化）

レビュー・検証サブエージェントは、環境依存の検証 track を**自分の一般知識にある既定値**で probe して「利用不能」と結論することがある。repo が別の接続先・別の起動 script を正本にしていると、実際には実行できる track が誤って `未実行` として監査に残る。

`未実行` は PASS ではないので一見安全側に見えるが、実害がある。required track の実測証拠が欠けたまま push 判断へ進み、監査記録には「この環境では動かせなかった」という**誤った環境事実**が残って次のセッションへ伝播する。

具体例（PR #1121）: final merge-blocker review のサブエージェントが `pg_isready -h localhost -p 5432` を見て DB 不在と判断し、required の server-integration track を「未実行」と報告した。実際には repo の `dev/scripts/with-server-integration-db.sh` が既定接続先を別ポートに定義しており、親が正本 script 経由で実行して該当 test は PASS した。

## 見分け方

- サブエージェントの報告に、`環境変数が未設定` `port に応答がない` `DB / service が利用できない` を根拠とした未実行項目がある。
- その根拠が、**repo の script や設定ではなく一般的な既定値**（標準ポート、慣用的な env 変数名）に基づいている。
- 同じ track を repo の CI が日常的に回している。

## 再発防止（How to apply）

1. サブエージェントの「環境が無い」という主張を、監査記録へ写す前に必ず親が検証する。能力の不在は結論であって観測ではない。
2. 検証先は repo の正本 runner（`dev/scripts/` の起動 script、CI workflow、`check.sh` の track 定義）から読む。サブエージェントが試した接続先ではなく、**script が定義する接続先**を確認する。
3. 実行できるなら親が実行し、監査には親の実測結果を記録する。サブエージェントの未実行報告と食い違った事実は、食い違い自体も含めて残す。
4. 本当に実行不能なら、`未実行` として理由・試した正本 command・代替証拠の所在を分けて書く。PASS と混ぜない。
5. サブエージェントへ環境依存の検証を任せるときは、prompt に repo の正本 runner command をそのまま渡す。probe 方法の裁量を与えない。

## 関連

- `[[non-idempotent-response-boundary-and-final-review-convergence]]`: final review の verdict は exact HEAD にしか効かない。本 memory は同じ review の**証拠の出所**側の注意点。
- 親エージェントは指摘だけでなく、サブエージェントが「確認できなかった」と述べた範囲も精査する。
