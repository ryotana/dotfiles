%W[
  #{node[:userhome]}/bin
  #{node[:userhome]}/repos
  #{node[:userhome]}/.config
  #{node[:userhome]}/.config/fish
  #{node[:userhome]}/.config/fish/conf.d
  #{node[:userhome]}/.claude
  #{node[:userhome]}/.config/gitleaks
  #{node[:userhome]}/.config/playwright-mcp
  #{node[:userhome]}/.aws
].each do |dir|
  directory dir do
    owner node[:username]
    group node[:usergroup]
  end
end

include_cookbook "dotfiles"

%w[
  .gitconfig
  .gitignore
  .rgignore
  .tigrc
  .my.cnf
  .vimrc
  .config/git-hooks
  .config/fish/config.fish
  .config/fish/functions
  .config/fish/conf.d/claude.fish
  .config/gitleaks/.gitleaks.toml
  .claude/CLAUDE.md
  .claude/no-mcp.json
  .claude/rules
].each do |link|
  dotfile_link link
end

dotfile_merged_json ".claude/settings.json" do
  base ".claude/settings.base.json"
  overlay node[:is_darwin] ? ".claude/settings.darwin.json" : ".claude/settings.linux.json"
end

dotfile_merged_json ".claude/mcp.json" do
  base ".claude/mcp.base.json"
end

Dir.glob(File.expand_path("../files/bin/*", __FILE__)) do |bin|
  link File.join(node[:userhome], "bin", File.basename(bin)) do
    to bin
    user node[:username]
    force false
    action :create
  end
end

execute "init playwright-mcp storage state" do
  command <<~CMD
    printf '{"cookies":[],"origins":[]}\\n' > #{node[:userhome]}/.config/playwright-mcp/storage-state.json
    chown #{node[:username]}:#{node[:usergroup]} #{node[:userhome]}/.config/playwright-mcp/storage-state.json
    chmod 644 #{node[:userhome]}/.config/playwright-mcp/storage-state.json
  CMD
  not_if "test -f #{node[:userhome]}/.config/playwright-mcp/storage-state.json"
end
