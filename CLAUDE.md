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

## アーキテクチャ

### 実行フロー (lib/bootstrap.rb)

1. プラットフォーム検出 → `nodes/darwin.rb` または `nodes/linux.rb` を読み込み
2. `nodes/common.rb` を読み込み（username, userhome, usergroup）
3. ホスト名固有のノードファイルがあれば読み込み（`nodes/<hostname>.rb`）
4. `roles/common` + プラットフォーム別ロール（`roles/darwin` or `roles/linux`）を読み込み
5. `node[:plugins]` 配列の各プラグインを読み込み
6. `node[:cookbooks]` 配列の各クックブックを読み込み

### ディレクトリの役割

- **lib/bootstrap.rb** — ヘルパーメソッド群（`include_node`, `include_role`, `include_cookbook`, `include_plugin`, `plugin_fragments`, `plugin_template_fragment`）と実行シーケンス。
- **nodes/** — 属性定義のみ。`node.reverse_merge!` で値を設定。リソース作成は禁止。
- **roles/** — リソースを作成するレシピ群。`default.rb` と任意の `files/` を持つ。
- **cookbooks/** — 再利用可能な DSL 定義。`dotfiles/default.rb` が `dotfile_link` と `dotfile_template` ヘルパーを提供。
- **dotfiles/** — `$HOME` にシンボリックリンクされる実際の設定ファイル群。
- **plugins/** — 環境固有の設定。`node.rb`、`recipes/default.rb`、`dotfiles/`、`templates/` を持つ。プライベートリポジトリをクローンする事を想定。

### dotfile の追加手順

1. `dotfiles/` にファイルを配置（例: `dotfiles/.myconfig`）
2. ロールのレシピ（通常 `roles/common/default.rb`）に `dotfile_link ".myconfig"` を追加

テンプレート化する場合は `dotfiles/` に `.erb` 拡張子で配置し、`dotfile_template` を使用する。

### プラグインシステム — 環境分離

プラグインで環境ごとの設定を分離する。
**最重要制約: 本リポジトリはパブリック公開されるため、顧客情報を含むプラグインは別のプライベートリポジトリで管理すること。**
ホスト名固有のノードファイルの `node[:plugins]` 配列でどのプラグインを有効にするか制御する。

```
plugins/<name>/
├── node.rb              # 環境固有の属性
├── recipes/default.rb   # 環境固有のリソース
├── dotfiles/            # plugin_fragments() で集約されるフラグメント
└── templates/           # plugin_template_fragment() で集約されるフラグメント
```

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
