# CLAUDE.md (User-level)

## 基本方針
- 日本語を使用する
- タイムゾーンはJSTを使用する
    - UTCで表現されている情報はJSTも明記すること
- 簡潔さを重視する
    - 冗長な説明や不要なコメントは避ける
- 既存のコードスタイルに合わせる
    - 新しい規約を持ち込まない
- 変更は最小限にする
    - 依頼された範囲を超えた「改変・改善」は行わない

## 環境
- 対話シェルはfish shellを基本とする
    - 共用可能なスクリプトや成果物向けのコマンドはbashで記載する
- パッケージマネージャ: Homebrew (macOS/Linux)
- 言語バージョン管理: anyenv (rbenv, nodenv, pyenv, goenv)
- インフラ: Terraform, AWS / Google Cloud
- コンテナ: Docker, Kubernetes

## 使用ツール
- 環境切り替え: direnv
- ファイル検索: fd
- ファイル内検索: rg
- 曖昧検索: fzf
- コード検索: ast-grep
- コード分析: scc
- 分析: jq / jo / yq
- 置換: sd
- リンター: tflint / shellcheck / yamllint / actionlint
- Github: gh
- セキュリティ: gitleaks
- 並列作業: parallel

## ファイル生成
- 成果物やスクリプトはプロジェクト内の `.claude/output` に適切なディレクトリを切って保存する
    - ユーザのホームディレクトリを汚さないように意識する
- 一時的に使用するだけのファイルはプロジェクト内の `.claude/tmp` に適切なディレクトリを切って保存する

## ファイル読み込み
- 1Mコンテキストをフル活用し、ファイルを編集する前は必ず全体をReadツールで読むこと
- head, tail, grep, rg でファイルの一部だけ推測して編集しないこと
    - ただし、明らかに巨大なファイル（ログ等）は例外とする
