# Git discovery fixture は base ref を自分で所有する

## 発生した問題（抽象化）

Git discovery の各失敗段階を検証する fixture が、開発者の full clone にある `main` / `origin/main` を暗黙に利用していた。local test は通ったが、GitHub Actions の depth-1 merge checkout には両 ref がなく、fixture は狙った `git diff` failure より前の base resolution で停止した。その結果、production の診断ではなく fixture 自身の環境依存で hosted tooling gate が落ちた。

## 再発防止（How to apply）

1. base diff、working diff、staged、untrackedなど特定のGit failure stageを検証するfixtureは、そこへ到達する前提もfixture自身で所有する。base commitは現在HEADなど既知のdeterministic SHAへ解決し、runnerのlocal branch / remote-tracking refに依存しない。
2. missing-base fixtureと後段stage failure fixtureを分ける。後段fixtureでbase resolutionまで失敗させると、assertしている診断の責任範囲が曖昧になる。
3. fixture用fallbackはtest wrapperの明示behaviorに限定し、production discovery semanticsへ流入させない。
4. Git routing testはfull cloneだけでなく、branch refが存在しないdepth-1 checkout相当でも実行できる形にする。hosted failureを直したら、local targeted testに加えてhosted exact-SHA gateで確認する。

## 見分け方

「期待したstage diagnosticが無い」というfailureでは、production messageを先に変えず、fixtureが本当にそのstageまで到達したかを確認する。checkoutのfetch depth、`git show-ref`、wrapperが返すbase SHAが主要な証拠になる。
