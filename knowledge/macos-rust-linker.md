# macOSでSQLx proc macroのロードが失敗する場合

canonical test runnerがSQLxのproc macro dylibをロードする段階で `mis-aligned LINKEDIT string pool` により停止した場合、テストの失敗ではなくビルド環境の失敗として区別する。テスト0件を成功扱いせず、必要なDB受入テストの証拠が得られるまで未実行と記録する。

まず共有・既存artifactを削除せず、task固有の新しい `CARGO_TARGET_DIR` で再buildする。それでも同じloader失敗が続く場合、strip設定を確認する。Rust 1.96.0 / LLVM22.1.2、Apple clang21 / ld-27037.1では、新targetだけでは回復せず、command-local `RUSTFLAGS='-C strip=none'` でSQLxのロードと実DB HTTP・CLI回帰が成功した。[Rust upstream issue #157750](https://github.com/rust-lang/rust/issues/157750)のMach-O string pool alignment問題に対応する回避策であり、依存やSQLx pinの変更を要しない。

```sh
# task_target は既存artifactとは別の、このtask専用directory。
CARGO_TARGET_DIR="$task_target" RUSTFLAGS='-C strip=none' \
  bash dev/scripts/with-server-integration-db.sh \
  cargo test -p aachat-server --features integration-db-tests \
  --test server_integration <test-filter>
```

このrunnerを使う場合は要求されたBash版を確認し、明示実行だけでなくPATHでもnested `bash` に同じ版を届ける。隔離DB runnerがmigration・preflight・cleanupを所有する経路を維持する。既存RUSTFLAGSがあれば、必要なflagsとstrip指定の優先順位を確認してから調整し、無条件に上書きしない。globalな設定は変更しない。

strip回避策の検証例: [[aachat/projects/aachat/pr-steward02/docs/pr-steward-audit/1807-4a16807b.md]]。新target初回は実行0件・exit101、回復後はCLI関連14件と実DB HTTP6件・exit0。quick CIの成功だけでは追加回帰の実行証拠にならない。

Apple Silicon、Rust 1.96.0、Apple linker ld-27037.1の組合せでは、Rust付属LLDとインストール済みMacOSX26.5 SDKをコマンド単位で指定することで、SQLxとserverのビルド、実DB統合テスト、unit testが成功した実例がある。LLDだけを指定して既定MacOSX27 SDKを使うと、libSystem等のTAPIファイルを `malformed file` として読み込めなかった。これは全環境に適用する既定設定ではなく、同じ失敗時の限定的な検証経路である。

使用する前に `rustc --version`、`rustc --print sysroot`、`rustc -vV`、`xcrun --show-sdk-path` で現在のtoolchainとSDKを確認する。Rust付属の `lib/rustlib/<host>/bin/gcc-ld/ld64.lld` と利用可能なSDKを実ファイルで確認し、存在するものだけを使う。SDKの追加インストールやglobalなXcode選択変更はこの方法の前提ではない。

確認した実在パスをtask固有の変数に入れ、既存runnerをそのまま実行する。値を永続設定へ書き込まない。

```sh
# task_sdk は確認済みSDK、task_lld は確認済みRust付属ld64.lldのパス。
SDKROOT="$task_sdk" RUSTFLAGS="-C link-arg=-fuse-ld=$task_lld" \
  bash dev/scripts/test-server-integration.sh --test server_integration <test-filter>
```

既存RUSTFLAGSが設定されていれば、役割を確認せず上書きしない。runnerの隔離DB、migration、cleanupを維持し、実際に実行された名前と件数を記録する。成功した場合も、標準環境での失敗と別のSDK/linker条件での成功を区別する。コンパイルが通ったことだけを受入テスト成功としない。

同じ原因への無制限な再試行や依存ライブラリの修正を避ける。適用できない環境では元の診断を残し、必要な検証を実行できる環境へ引き継ぐ。

検証例: [[aachat/projects/aachat/pr-steward/docs/pr-steward-audit/1425-a4677c03.md]]。この文書は環境診断の参照情報であり、PR固有の進捗や完了状態はauditを正本とする。
