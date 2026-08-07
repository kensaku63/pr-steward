# レビュー優先度基準

親エージェントがサブエージェントの指摘を精査し、優先度を付けるときの正本。

## 精査チェックリスト

親エージェントはサブエージェントの出力を直接採用してはならない。各指摘について次を確認する。

- 証拠性: PR 差分、既存仕様、テスト失敗、実行ログ、再現手順のいずれかに基づくか。
- merge-blocker 性: 本番障害、データ破壊、セキュリティ問題、重大な UX 劣化、CI 失敗につながるか。
- スコープ適合性: PR 目的に対する修正であり、unrelated refactor ではないか。
- 複雑さ: 解決方針が過度に大きくないか。最小修正で目的を満たせるか。
- repo 方針との整合: 既存設計、命名、テスト方針、運用方針に沿っているか。
- 実装可能性: 変更箇所、期待挙動、検証方法が十分具体的か。
- UX 妥当性: 対象ユーザー、利用シナリオ、問題が起きる状態、最小の改善案が示されているか。好みや大規模再設計になっていないか。
- テスト必要性: 守るべき振る舞い、壊れやすい変更点、既存テストで検知できない理由、最小のテスト形態が示されているか。
- 副作用リスク: shared code、public API、DB schema、認可、非同期処理、既存互換性に触れるか。
- 人間判断の要否: 仕様、UX、API、スコープ判断が必要か。

GitHub PR 上の Cursor / Codex / 人間 reviewer の指摘にも、同じ基準を適用する。author や review tool の評判を根拠に採否を決めない。

## 認知負荷を超えない精査手順

親エージェントは全指摘を一度の prompt / 判断で処理しない。

1. まず全 candidate を lossless に intake ledger へ固定し、source と stable ID を付ける。
2. 同じ根本原因・失敗条件・修正対象を持つ candidate を cluster 化する。cluster 化は整理であり、採否判断ではない。
3. 原則最大 5 cluster の batch に分ける。P0候補、security、認証、データ破壊は 1 cluster ずつ扱う。
4. 各 cluster について、必要な diff・仕様・テスト・実行証拠だけを読み直し、この checklist で disposition を決める。
5. batch ごとに ledger と issue doc を更新して判断を外部化し、未処理件数を再計算してから次へ進む。
6. 全 batch 後に横断重複と優先度の整合だけを別 pass で確認する。個別課題の詳細判定と全体最適化を同時に行わない。

完了時には、次の件数が保存則を満たすことを確認する。

```text
collected candidates
= accepted + rejected + deferred + duplicate + superseded
```

`untriaged` が 1 件でも残る場合、実装計画を確定しない。context 不足や時間不足で精査品質を維持できない場合は、未処理範囲を明示して次 session へ handoff し、完了扱いにしない。

## 重複排除

- 同じ根本原因、同じ修正対象、同じ失敗条件、同じ影響、片方の解決でもう片方も解消するものは 1 課題に統合する。
- 重複 doc は `status: duplicate` と `duplicate_of` で元 doc を参照する。

## 優先度

- `P0`: merge blocker。データ破壊、重大セキュリティ、主要機能停止、復旧困難。
- `P1`: マージ前修正必須。明確なバグ、高影響の回帰、仕様未達。
- `P2`: PR スコープ内なら修正。限定的不具合、必要性が説明できる安全網不足、運用上の注意。
- `P3`: follow-up 可。軽微な改善、低リスクの保守性課題。
- `defer`: 今回は扱わない。人間判断または別 PR が適切。

## 実装順序

1. P0 と CI 失敗原因を最優先にする。
2. 同じファイル・同じ責務に属する修正はまとめる。
3. 依存関係がある場合は、基盤修正、型・契約修正、利用側修正、テスト修正の順に進める。
4. PR 目的から外れる改善、任意リファクタ、好みの問題は実装対象から外す。

## テスト指摘の採用基準

- テスト追加は、カバレッジの数値改善ではなく、変更で壊れたら困る振る舞いを固定するために提案する。
- 既存テストで同じリスクを検知できる場合、新規テストは提案しない。
- テストが必要な場合は、unit / integration / characterization / golden / contract / e2e のどれが最小で十分かを示す。
- リファクタリングや構造変更に安全網がない場合は、まず現在の振る舞いを固定する characterization test を提案する。
- テストが private detail を固定し、将来の安全な変更を妨げる場合は、追加ではなく外部契約を固定する形への書き換えを提案する。

## Rolling compatibility と snapshot freshness

- client / server、CLI / API のように別々に配備される契約変更では、release順を証拠として確認し、new client → old server と old client → new server の両方向をcontract testで固定する。片方向だけの互換性はrolling releaseの安全性を証明しない。
- legacy clientの不完全snapshotではdeactivateを省略してよいが、source watermarkや世代判定を迂回してはならない。stale snapshotは既存rowの復活だけでなく、削除済みの未登録rowのinsertもno-opでなければならない。
- payload budgetのため本文を省略する場合、hashやdigestが変わったrowに旧cacheを残さない。metadataだけでbudgetを超える場合も主要処理を停止させず、無効なpartial reportを送らない挙動を境界testで固定する。
