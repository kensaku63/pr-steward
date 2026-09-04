# PR checks が緑でも merge 後の gate は別物として自分で回す

## 発生した問題（抽象化）

対象 repo の PR checks は静的検査の一部しか実行せず、lint の厳格 gate、全 test、production build は merge 後の push CI が担う設計だった。その結果、PR は hosted checks で緑のまま、workspace 全体の lint を `-D warnings` で回すと error が 4 件出る状態になっていた。merge すれば main の CI が赤くなり、そのコミットの production 反映資格も失われる。PR checks の結果だけを delivery evidence として扱っていたら、この状態のまま push していた。

## 再発防止（How to apply）

1. 対象 repo の品質ゲートが「PR で回るもの」と「merge 後にだけ回るもの」に分かれていないかを、stewardship の早い段階で確認する。分かれているなら、merge 後にだけ回る command を自分で実行する。
2. lint は特に注意する。PR track が format と compile だけを見て、厳格な lint を merge 後に回す構成は珍しくない。`-D warnings` 相当の設定なら warning も merge blocker になる。
3. 見つかった gate 違反が元の PR 由来なら、それは merge blocker である。approved fix plan に無くても、振る舞いを変えない機械的な修正で閉じられるなら閉じる。閉じた事実と理由を audit record と PR コメントに plan 外の変更として明示する。
4. hosted checks を証拠にするときは exact SHA の run を見る。`skipping` の job を PASS と数えない。差分に該当しなかったのか、実行されて通ったのかを分けて記録する。
