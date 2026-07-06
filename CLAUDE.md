# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

mitamae ベースの dotfiles 管理システム。mitamae は Chef ライクな Ruby DSL のインフラ構成管理ツール。macOS（darwin）と Amazon Linux 2023（amazon）をサポートし、ホスト名ごとに有効化するプラグイン・クックブックを切り替える。

## コマンド

```bash
# ドライラン（変更のプレビュー、デフォルト）
sudo ./run.sh

# 変更を適用
sudo ./run.sh -x
```

- `sudo` 必須。`$SUDO_USER` で対象ユーザーを判定する（`run.sh` が `USER` / `USERNAME` / `LOGNAME` を `$SUDO_USER` に上書きしてから mitamae を実行する）。
- `run.sh` は `bin/mitamae local lib/bootstrap.rb`（適用時）/ 同 `--dry-run`（既定）を呼ぶ。`bin/mitamae` はラッパースクリプトで、プラットフォーム別バイナリ（`mitamae-x86_64-linux` / `mitamae-x86_64-darwin` / `mitamae-aarch64-darwin`、`v1.14.4`）が無ければ GitHub release から自動ダウンロードする（バイナリは `.gitignore` 対象）。
- レシピやテンプレートを変更した場合は `sudo ./run.sh` でドライランを実行し、意図通りの差分になっているか確認すること。

```bash
# リポジトリ本体 + plugins/* を git 同期
./sync.sh
```

`sync.sh` は本体リポジトリと `plugins/*/`（`.git` を持つもの）それぞれで `git fetch` → `git merge-tree` で競合判定 → 競合なければ `git pull`、ローカルが先行していれば `git push` を行う。競合時はそのリポジトリをスキップする。

## アーキテクチャ

### 実行フロー (lib/bootstrap.rb)

`lib/bootstrap.rb` がエントリポイント。先頭でヘルパー（`include_node` / `include_role` / `include_cookbook` / `include_plugin` / `plugin_fragments` / `plugin_template_fragment`）を定義し、続けて以下の順で recipe を読み込む。

1. mitamae が検出した `node[:platform]` に応じてプラットフォームノードを読み込み（"darwin" → `nodes/darwin.rb`、"redhat"/"amazon" → `nodes/linux.rb`）。ここで `is_darwin` / `is_arm` または `is_linux` が設定される
2. `nodes/common.rb` を読み込み（hostname, username, usergroup, userhome）
3. ホスト名固有のノードファイル `nodes/<hostname>.rb` があれば読み込み（plugins, cookbooks, brew, anyenv 等を設定）
4. `roles/common` + プラットフォーム別ロール（`roles/darwin` or `roles/linux`）を読み込み
5. `node[:plugins]` 配列の各プラグインを読み込み
6. `node[:cookbooks]` 配列の各クックブックを読み込み

`include_node` / `include_role` / `include_plugin` は対象ファイルが無ければスキップする。`include_cookbook` は存在前提で読み込む。

### ディレクトリの役割

- **lib/bootstrap.rb** — ヘルパーメソッド群と実行シーケンス
- **bin/** — `mitamae` ラッパーと自動ダウンロードされた mitamae バイナリ（`bin/mitamae-*` は `.gitignore` 対象）
- **nodes/** — 属性定義のみ。`node.reverse_merge!` で値を設定。**リソース作成は禁止**
- **roles/** — リソースを作成するレシピ群。`default.rb` と任意の `files/` を持つ。`roles/common` が共通 dotfile のリンクと `dotfiles` クックブックの読み込みを行い、`roles/{darwin,linux}` がプラットフォーム固有の dotfile・`~/bin` スクリプト・（Linux のみ）cloud-init スクリプト（`/var/lib/cloud/scripts/per-boot/`）を配置する
- **cookbooks/** — 再利用可能な設定単位。`dotfiles` クックブックが `dotfile_link` / `dotfile_template` / `dotfile_merged_json` ヘルパーを提供し、`roles/common` から `include_cookbook "dotfiles"` で読み込まれる。その他はホスト名ノードの `node[:cookbooks]` で有効化する（後述）
- **dotfiles/** — `$HOME` にシンボリックリンク（または template / merged_json で生成）される実際の設定ファイル群
- **plugins/** — 環境固有の設定（後述）

### クックブック

`node[:cookbooks]` で有効化する（`dotfiles` のみ `roles/common` から常に読み込まれる）。

| クックブック | 役割 |
|------|------|
| `dotfiles` | `dotfile_link` / `dotfile_template` / `dotfile_merged_json` の define を提供 |
| `homebrew` | Homebrew / Linuxbrew の導入と `node[:brew]`（tap, packages, cask_packages）の適用。`default.rb` が `darwin.rb` / `linux.rb` に分岐 |
| `anyenv` | anyenv を `~/.anyenv` に導入し、`node[:anyenv]`（plugins, envs）に従って rbenv/nodenv 等をインストール |
| `tmux` | tpm の導入、`~/.tmux.conf` をテンプレートから生成、ステータス表示スクリプトを `~/bin` にリンク |
| `docker` | AL2023 は dnf で docker engine・docker-compose・buildx を導入し月次 `docker-prune` の systemd timer を設定、macOS は `homebrew` クックブックを内部で読み込み Docker Desktop（brew cask）を導入 |
| `public-nginx` | `docker` クックブックを内部で読み込み、`/var/www/public` を docker compose の nginx で配信。symlink は AL2023 が `~/public`、macOS が `~/public-www`（既定の `~/Public` と衝突するため）。AL2023 は systemd --user サービス、macOS は LaunchAgent として常駐 |

### dotfile の追加手順

1. `dotfiles/` にファイルを配置（例: `dotfiles/.myconfig`）
2. ロールのレシピ（通常 `roles/common/default.rb`）に `dotfile_link ".myconfig"` を追加

テンプレート化する場合は `dotfiles/` に `.erb` 拡張子で配置し、`dotfile_template ".myconfig"` を使用する。複数 JSON を deep merge する場合は `dotfile_merged_json` を使う（後述）。

### ホスト名ノードファイル

ホストごとの設定は `nodes/<hostname>.rb` に記述する。`nodes/sample-hostname.rb` がサンプルで、`plugins` / `cookbooks` / `brew` / `anyenv` を設定する。ホスト名ノードファイルは `nodes/common.rb`, `nodes/darwin.rb`, `nodes/linux.rb`, `nodes/sample-hostname.rb` 以外 `.gitignore` で除外されるため、環境固有の情報を安全に記述できる。

### プラグインシステム — 環境分離

プラグインで環境ごとの設定を分離する。
**最重要制約: 本リポジトリはパブリック公開されるため、顧客情報・企業名を含むプラグインは別のプライベートリポジトリで管理すること。**
ホスト名固有のノードファイルの `node[:plugins]` 配列でどのプラグインを有効にするか制御する。`plugins/*` は `.gitignore` で全除外され、各プラグインは独立した git リポジトリとして `plugins/<name>/` に clone する（`sync.sh` が個別に同期する）。

```
plugins/<name>/
├── node.rb              # 環境固有の属性（include_plugin が最初に読み込む）
├── recipes/default.rb   # 環境固有のリソース（必要なら darwin.rb / linux.rb を include_recipe）
├── dotfiles/            # plugin_fragments() / dotfile_merged_json で集約されるフラグメント
├── templates/           # plugin_template_fragment() で集約されるフラグメント
└── files/               # bin スクリプトや cloud-init 等
```

`include_plugin` は `plugins/<name>/node.rb` → `plugins/<name>/recipes/default.rb` の順に（存在すれば）読み込む。

**フラグメント集約**: プラグインごとに分割した設定を 1 ファイルに集約する仕組み。recipe 内（`roles/*/default.rb` 等）で `plugin_fragments("some/path")` を呼ぶと、有効な全プラグインの `dotfiles/some/path/*` をファイル名の辞書順に結合した文字列を返す（`plugin_template_fragment("file")` は各プラグインの `templates/file` を結合）。結果は `dotfile_template` の `vars` 経由で ERB に渡して埋め込む。mruby 版 mitamae の ERB からはヘルパーや `JSON` を直接呼べないため、必ず recipe 側で評価して `vars` で渡すこと。実例: `roles/{darwin,linux}/default.rb` がプラットフォーム別フラグメント（`.aws/config.darwin.d` / `.aws/config.linux.d`）を集約し `dotfiles/.aws/config.erb`（`@plugin_fragments` を参照）に渡す。

**JSON 設定の集約**: JSON は文字列結合できないため `dotfile_merged_json` を使う。`dotfiles/<base>` のベースと有効プラグインの `dotfiles/<name>` 断片を jq の `*` 演算子（deep merge、`jq -s 'reduce .[] as $x ({}; . * $x)'`）でマージして `$HOME/<name>` を生成する。ベースが先・プラグインが後にマージされる（プラグイン側が上書き）。実例: `roles/common/default.rb` の `.claude/settings.json`（ベースは `dotfiles/.claude/settings.base.json`、差分は各プラグインの `dotfiles/.claude/settings.json`）。

**define ヘルパーのパラメータはブロック構文で渡す**: `dotfile_link` / `dotfile_merged_json` 等の define 生成ヘルパーへのパラメータは、`dotfile_link ".myconfig" do source "/path/to/plugin/dotfiles" end` のようにブロック内で設定する（`dotfile_link ".x", source: "..."` のインライン引数形式は `wrong number of arguments` で不可）。プラグイン固有の dotfiles をリンクする場合は `source` にそのディレクトリを指定する（例: `plugins/<name>/recipes/*.rb` で `source File.join(PLUGIN_DIR, "dotfiles")`）。

### 主要なノード属性

| 属性 | 説明 |
|------|------|
| `node[:platform]` | 自動検出（"darwin", "redhat", "amazon"） |
| `node[:is_darwin]`, `node[:is_linux]` | プラットフォームフラグ |
| `node[:is_arm]` | ARM アーキテクチャ（darwin で `uname -m` が arm64） |
| `node[:hostname]` | システムのホスト名 |
| `node[:username]` | `$SUDO_USER` から取得 |
| `node[:userhome]` | ホームディレクトリ（Linux は mitamae の `node[:user][...][:directory]`、macOS は `$HOME`） |
| `node[:usergroup]` | macOS では "staff"、Linux ではユーザー名 |
| `node[:plugins]` | 読み込むプラグイン名の配列（ホスト名ノードで設定） |
| `node[:cookbooks]` | 読み込むクックブック名の配列（ホスト名ノードで設定） |
| `node[:brew]` | `homebrew` クックブック用。`tap` / `packages` / `cask_packages` |
| `node[:anyenv]` | `anyenv` クックブック用。`plugins`（名前→repo）/ `envs`（rbenv 等） |
