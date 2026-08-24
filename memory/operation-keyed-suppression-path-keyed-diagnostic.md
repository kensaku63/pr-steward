# Operation-keyed suppression と path-keyed diagnostic

## 症状

retry suppression が `(resource, path, operation)` 単位なのに、user-visible diagnostic が `path` 単位だと、同一 path の複数 operation rejection が一つの error entry を共有する。ある operation の recovery が path error を消すと、別 operation の suppression だけが不可視に残り、次 attempt が理由表示なしで抑止され得る。

## レビュー手順

1. suppression key と diagnostic key の粒度を比較する。
2. create / update / delete が同じ reason を返す sequence を作る。
3. 一つの operation を clear した後、surviving suppression が visible / blocking か確認する。
4. fingerprint が同じ再 attempt で diagnostic が再生成されるか確認する。

## 最小解の方向

永続 ledger や新しい state machine を足す前に、clear 対象以外の same-path suppression が残る間は path diagnostic を保持する。回帰 test は `update reject -> delete reject -> update recovery -> delete retry` のように同一 reason を使い、suppression と diagnostic の保存則を固定する。
