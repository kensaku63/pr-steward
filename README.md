# pr-steward

PR Steward は、指定された GitHub Pull Request をマージ可能な状態へ安全に整える aachat agent です。

マージ価値の判定（merge value gate）、4 観点の並列レビュー、指摘の精査と実装計画化、修正実装、最終 merge-blocker review、PR ブランチへの push までを 1 つのワークフローとして実行します。

## できること

- PR の目的・差分・リスクを読み、後続レビューに進める価値を `pass` / `needs-human` / `reject` で判定する。
- Outcome Gap / UX Friction / Code Quality / Release Hardening の 4 観点でレビューサブエージェントを並列起動し、課題を集める。
- サブエージェントの指摘を証拠・影響・スコープ・複雑さで精査し、重複排除と優先度付け（P0〜P3 / defer）を行う。
- 承認済み実装計画を新しい実装セッションに handoff し、最小限の修正だけを実装させる。
- 実装後に merge blocker が残っていないかだけを判定する最終レビューを、実装セッション内のサブエージェントで実行する。
- 安全チェックを満たした場合のみ PR head branch へ通常 push する。
- レビュー課題、実装計画、監査ログを aachat shared document に残し、GitHub PR コメントは簡潔な結論に限定する。

## 向いている依頼

- 「この PR をマージできる状態にして」
- 「この PR、マージする価値があるか判定して」
- 「この PR をレビューして、直すべき点を直して push して」
- 「外部コントリビューターの PR を安全に取り込みたい」

## 使い方

```bash
aachat agent clone owner/pr-steward --name pr-steward
```

clone 後、project に参加させてから session を起動します。

```bash
aachat project assign <project> --agent pr-steward
aachat session run pr-steward --project <project> "https://github.com/<owner>/<repo>/pull/<number> をマージ可能な状態にして"
```

対象 PR は PR URL または PR number で明示してください。

## ワークフロー

1. `pr-checkout`: PR の特定と安全な checkout。
2. `merge-value-gate`: マージ価値の判定。`reject` は例外扱いで、迷ったら人間判断に倒す。
3. `parallel-pr-review`: 4 観点レビューの並列実行。
4. `review-issue-docs`: 課題 1 件につき 1 つの aachat shared document を作成。
5. 親エージェントによる指摘の精査・重複排除・優先度付け・実装計画の確定。
6. `implementation-handoff`: 新しい実装セッションへの handoff。
7. `final-merge-blocker-review`: 実装後の merge-blocker 判定（実装セッション内のサブエージェントで実行）。
8. `pr-push-safety`: push 前チェックと通常 push。

## 安全方針

- force push、rebase、history rewrite、conflict の自動解消は行わない。
- PR の merge / close / approve / request changes は人間の明示承認が必要。
- 仕様変更、UX 判断、API 契約変更、DB migration、認証・認可・課金・データ削除に関わる変更は人間判断へ回す。
- secret、credential らしき差分を検出したら停止する。
- 同一 PR / 同一セッションの自動 fix-and-push は最大 3 回まで。

詳細は `knowledge/human-approval-policy.md` を参照してください。

## 構成

- `identity.md`: エージェントの役割、行動原則、workflow と skill の対応の正本。
- `environment.yaml`: 必要な実行環境。依存は `config.packages` に、必要な env 名は `config.env[]` に書く。
- `memory/`: session 間で引き継ぐ未完了状態、push 回数、再開手順。
- `knowledge/`: GitHub PR 操作手順、レビュー doc schema、優先度基準、人間承認ポリシー。
- `.agents/skills/`: この agent 専用の実行時 skill。Discovery の子 skill カタログもここを優先して見る。

## 実行時 Skill

- `pr-checkout`: 対象 PR の特定、working tree 確認、安全な checkout。
- `merge-value-gate`: `pass` / `needs-human` / `reject` の判定基準とガードレール。
- `parallel-pr-review`: 4 観点レビューサブエージェントの起動と共通ルール。
- `review-issue-docs`: レビュー課題の shared document 化と frontmatter 規約。
- `implementation-handoff`: 承認済み実装計画の新セッションへの引き継ぎ。
- `final-merge-blocker-review`: 実装後の merge-blocker 限定レビュー（実装セッション内のサブエージェントで実行）。
- `pr-push-safety`: push 前チェックリストと push ルール。

## 必要な権限と env

GitHub 操作には `gh` CLI を使います。session 環境で `gh auth status` が通る状態、または `GH_TOKEN` が解決できる状態にしてください。

```yaml
# environment.yaml
config:
  env:
    - name: GH_TOKEN
      purpose: GitHub API access for gh CLI (PR view / checkout / comment / push)
```

## 注意

secret、token、JWT、PAT、秘密鍵は repo に含めないでください。
secret が必要なときは `environment.yaml` の `config.env[]` に env 名だけを書きます。
値・provider ref・ローカルパスは `~/aachat/.state/env.toml` などローカル設定にだけ置き、repo には含めません。

`description_ja` / `description_en` は Discovery submit 時の入力であり、repo 内の固定ファイルではありません。

### description_ja（submit 用候補）

PR Steward は、GitHub Pull Request をマージ可能な状態へ安全に整えるエージェントです。マージ価値の判定、成果・UX・コード品質・リリース安全性の 4 観点並列レビュー、指摘の証拠ベースの精査と優先度付け、最小限の修正実装、最終 merge-blocker review、安全確認付きの push までを行い、判断材料と監査ログは aachat shared document に、GitHub コメントは簡潔な結論だけに残します。破壊的 git 操作や仕様判断は人間承認に回します。

### description_en（submit 用候補）

PR Steward safely drives a GitHub pull request toward a mergeable state. It runs a merge-value gate, launches four parallel reviewers (outcome gap, UX friction, code quality, release hardening), validates findings against evidence before planning fixes, implements the approved minimal fixes in a fresh session, runs a final merge-blocker-only review as a subagent inside that session, and pushes with strict safety checks. Long-form reasoning and audit logs live in aachat shared documents; GitHub comments stay concise. Destructive git operations and spec-level decisions are escalated to humans.
