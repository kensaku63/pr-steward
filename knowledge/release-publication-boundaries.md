# Release publication boundaries

Release 分離や auto-update 導入を review するときは、新 workflow の内部だけでなく、配布済み client と mutable publication surface の境界を先に確認する。

## Consumer-first cutover audit

1. base 版の binary、installer、runbook が参照する固定 URL、tag、asset name を検索する。
2. `releases/latest` のような alias を複数 consumer が共有していないか確認する。例えば CLI installer と旧 App DMG が同じ Latest Release に依存する場合、片方だけを別 release 系列へ移すともう片方の固定 URL が切れる。
3. 新版を公開する前に、旧版から新版へ到達する一回限りの migration path、実機 acceptance、sunset 条件を確定する。
4. rolling compatibility が必要でも、恒久 fallback、第二 release authority、手動 copy protocol を review remedy として自動追加しない。既存 consumer を壊さない最短の bridge と明示的な終了条件を planning で比較する。

## Mutable stable asset is one transaction

Stable manifest や固定 asset の publication は、次を別々の guard ではなく一つの transaction contract として review する。

- availability: candidate upload が失敗しても直前の verified asset を読み続けられる。
- replay: draft/create/upload の途中失敗後、同じ release identity の retry が exact verified state へ収束する。
- monotonicity: 並行 run や古い rerun が現在の stable version を巻き戻さない。
- channel isolation: prerelease candidate が stable alias を変更しない。
- verification: source text の `grep` ではなく、fresh、partial、failed、stale、successful の remote mutation outcome を executable test で固定する。

GitHub CLI を使う場合、実行環境の `gh release upload --help` を再確認する。`--clobber` が旧 asset を先に削除する contract なら、upload 後の readback は digest を証明しても publication gap を防がない。

## Signing authority scope

Long-lived updater key は build input ではなく signing authority である。

- workflow step 全体の environment に置くと、contract tests、package scripts、compiler/build dependencies を含む全 child process が参照できる。
- key と password は verified artifact が完成した後、実際の signer subprocess の最小 scope にだけ渡す。
- key value を検査・ログ出力しない。review は secret name、process inheritance、使用地点だけで exposure boundary を判断する。
- 新しい signing service や key store を足す前に、既存 secret の process scope を縮めるだけで十分かを確認する。

