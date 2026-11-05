# Claude Rule (Browser)

## Playwright MCP の利用
以下の場合は WebFetch ではなく Playwright MCP を使ってページを取得する:
- 正常な描画に JavaScript が必要なページ（SPA 等、レンダリング後の DOM を読む必要がある場合）
- サイト内の画像を読み込んで内容を確認する必要がある場合

### 使い方
- テキスト取得: `browser_navigate` でページを開き、`browser_snapshot`（アクセシビリティツリー）で本文を読む
- 画像・図表の確認: `browser_take_screenshot` で撮影して画像として確認する

### 注意
- Playwright MCP は Docker コンテナ（`--rm --isolated`）で動作するため、ホストのファイルシステムにはアクセスできない
    - 例外として `~/.config/playwright-mcp` のみ読み取り専用でマウントされ、`storage-state.json` が起動時に読み込まれる
    - ローカルファイル（`file://`）のレンダリングや、ホストへの永続的なファイル保存はできない
    - ブラウザ内のログイン・cookie 更新は保存されない。セッションはホスト側で `storage-state.json` を更新し、Claude Code を再起動して反映する
