# Docker Desktop（engine / compose / buildx を同梱）
# 初回のみ GUI で Docker.app を起動して初期設定を完了させる必要がある
include_cookbook "homebrew"

execute "/bin/bash -c '#{BREW_PRE_CMD} && brew install --cask docker-desktop'" do
  user node[:username]
  not_if "test -d /Applications/Docker.app"
end
