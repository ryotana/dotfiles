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
- **cookbooks/** — 再利用可能な設定単位。`dotfiles` cookbook が `dotfile_link` / `dotfile_template` ヘルパーを提供。その他（homebrew, tmux, docker, anyenv）はノードの `node[:cookbooks]` で有効化
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

**フラグメント集約**: `dotfile_template` 内の ERB テンプレートから `plugin_fragments("some/path")` を呼ぶと、有効な全プラグインの `dotfiles/some/path/*` を結合して返す。`plugin_template_fragment("file.conf")` は `templates/file.conf` を結合する。これにより、プラグインごとに設定を分割しつつ一つのファイルに集約できる。

**dotfile_link の source パラメータ**: プラグインの recipes 内で `dotfile_link ".myconfig", source: "/path/to/plugin/dotfiles"` と指定すると、プラグイン固有の dotfiles ディレクトリからシンボリックリンクを作成できる。

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
