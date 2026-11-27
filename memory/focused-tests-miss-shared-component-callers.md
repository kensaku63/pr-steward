# PR本文のfocused testは共有コンポーネントの他callerを覆わない

2026-11-27、aachat PR #2907（`WorkspaceSelector` / `LocalFolderPicker` の操作変更）。PR本文のfocused 75件と変更spec 6件は成功していたが、Vitest全体とmock E2E全体を回すと、対象外の3件（設定画面のrequest一覧、mock route、Triggerのe2e）が旧操作・旧fixtureを期待して失敗していた。mainでは成功。PRの `Frontend checks` 成功はこれを検出していなかった。

共有UIコンポーネントの操作・文言・読取APIを変えるPRでは、focused setの成功を全体の成功と読まず、`pnpm --dir web exec vitest run`（約1分）と、廃止した文言の `git grep`、該当コンポーネントを通るmock E2Eを確認する。失敗はPR head・修正前head・mainで比べて起因を分ける。

補足（環境）: Bashはzshで、`$T` に複数pathを入れても単語分割されない。mock E2Eをtimeoutで切るとport 3318のnext-serverが残るので、cwdが自分のworkspaceか確かめてから止める。CI jobが数秒でfailureなら、annotationで「Actions budget」等の未起動を先に確認する。
