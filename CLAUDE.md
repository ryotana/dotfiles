# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

mitamae ベースの dotfiles 管理システム。mitamae は Chef ライクな Ruby DSL のインフラ構成管理ツール。

## コマンド

```bash
# ドライラン（変更のプレビュー、デフォルト）
sudo ./run.sh

# 変更を適用
sudo ./run.sh -x
```

`sudo` 必須。`$SUDO_USER` で対象ユーザーを判定する。

レシピやテンプレートを変更した場合は `sudo ./run.sh` でドライランを実行し、意図通りの差分になっているか確認すること。

## アーキテクチャ

### 実行フロー (lib/bootstrap.rb)

1. プラットフォーム検出 → `nodes/darwin.rb` または `nodes/linux.rb` を読み込み
2. `nodes/common.rb` を読み込み（username, userhome, usergroup）
3. ホスト名固有のノードファイルがあれば読み込み（`nodes/<hostname>.rb`）
4. `roles/common` + プラットフォーム別ロール（`roles/darwin` or `roles/linux`）を読み込み
5. `node[:plugins]` 配列の各プラグインを読み込み
6. `node[:cookbooks]` 配列の各クックブックを読み込み

### ディレクトリの役割

- **lib/bootstrap.rb** — ヘルパーメソッド群と実行シーケンス
- **nodes/** — 属性定義のみ。`node.reverse_merge!` で値を設定。**リソース作成は禁止**
- **roles/** — リソースを作成するレシピ群。`default.rb` と任意の `files/` を持つ
- **cookbooks/** — 再利用可能な設定単位。`dotfiles` cookbook が `dotfile_link` / `dotfile_template` / `dotfile_merged_json` ヘルパーを提供。その他（homebrew, tmux, docker, anyenv）はノードの `node[:cookbooks]` で有効化
- **dotfiles/** — `$HOME` にシンボリックリンクされる実際の設定ファイル群
- **plugins/** — 環境固有の設定（後述）

### dotfile の追加手順

1. `dotfiles/` にファイルを配置（例: `dotfiles/.myconfig`）
2. ロールのレシピ（通常 `roles/common/default.rb`）に `dotfile_link ".myconfig"` を追加

テンプレート化する場合は `dotfiles/` に `.erb` 拡張子で配置し、`dotfile_template ".myconfig"` を使用する。

### ホスト名ノードファイル

ホストごとの設定は `nodes/<hostname>.rb` に記述する。`nodes/sample-hostname.rb` がサンプル。ホスト名ノードファイルは `nodes/common.rb`, `nodes/darwin.rb`, `nodes/linux.rb` 以外 `.gitignore` で除外されるため、環境固有の情報を安全に記述できる。

### プラグインシステム — 環境分離

プラグインで環境ごとの設定を分離する。
**最重要制約: 本リポジトリはパブリック公開されるため、顧客情報・企業名を含むプラグインは別のプライベートリポジトリで管理すること。**
ホスト名固有のノードファイルの `node[:plugins]` 配列でどのプラグインを有効にするか制御する。`plugins/` ディレクトリ自体も `.gitignore` で除外される。

```
plugins/<name>/
├── node.rb              # 環境固有の属性
├── recipes/default.rb   # 環境固有のリソース
├── dotfiles/            # plugin_fragments() で集約されるフラグメント
└── templates/           # plugin_template_fragment() で集約されるフラグメント
```

**フラグメント集約**: プラグインごとに分割した設定を 1 ファイルに集約する仕組み。recipe 内（`roles/*/default.rb` 等）で `plugin_fragments("some/path")` を呼ぶと、有効な全プラグインの `dotfiles/some/path/*` を結合した文字列を返す（`plugin_template_fragment("file.conf")` は各プラグインの `templates/file.conf` を結合）。結果は `dotfile_template` の `vars` 経由で ERB に渡して埋め込む。mruby 版 mitamae の ERB からはヘルパーや `JSON` を直接呼べないため、必ず recipe 側で評価して `vars` で渡すこと。実例: `roles/linux/default.rb` → `dotfiles/.aws/config.erb`（`@plugin_fragments` を参照）。

**JSON 設定の集約**: JSON は文字列結合できないため `dotfile_merged_json` を使う。`dotfiles/<name>` のベースと有効プラグインの `dotfiles/<name>` 断片を jq の `*` 演算子（deep merge）でマージして `$HOME/<name>` を生成する。実例: `roles/common/default.rb` の `.claude/settings.json`（ベースは `dotfiles/.claude/settings.base.json`、EI 固有差分は `plugins/ei/dotfiles/.claude/settings.json`）。

**define ヘルパーのパラメータはブロック構文で渡す**: `dotfile_link` / `dotfile_merged_json` 等の define 生成ヘルパーへのパラメータは、`dotfile_link ".myconfig" do source "/path/to/plugin/dotfiles" end` のようにブロック内で設定する（`dotfile_link ".x", source: "..."` のインライン引数形式は `wrong number of arguments` で不可）。プラグイン固有の dotfiles をリンクする場合は `source` にそのディレクトリを指定する。実例: `plugins/ei/recipes/linux.rb`。

### 主要なノード属性

| 属性 | 説明 |
|------|------|
| `node[:platform]` | 自動検出（"darwin", "redhat", "amazon"） |
| `node[:is_darwin]`, `node[:is_linux]` | プラットフォームフラグ |
| `node[:is_arm]` | ARM アーキテクチャ |
| `node[:hostname]` | システムのホスト名 |
| `node[:username]` | `$SUDO_USER` から取得 |
| `node[:userhome]` | ホームディレクトリ |
| `node[:usergroup]` | macOS では "staff"、Linux ではユーザー名 |
| `node[:plugins]` | 読み込むプラグイン名の配列 |
| `node[:cookbooks]` | 読み込むクックブック名の配列 |
