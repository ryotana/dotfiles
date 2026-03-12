%W[
  #{node[:userhome]}/bin
  #{node[:userhome]}/repos
  #{node[:userhome]}/.config
  #{node[:userhome]}/.config/fish
  #{node[:userhome]}/.config/fish/conf.d
  #{node[:userhome]}/.claude
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
  .tigrc
  .my.cnf
  .vimrc
  .config/fish/config.fish
  .config/fish/functions
  .config/fish/conf.d/claude.fish
  .claude/settings.json
  .claude/mcp.json
  .claude/no-mcp.json
].each do |link|
  dotfile_link link
end

_aws_fragments = plugin_fragments(".aws/config.d")
dotfile_template ".aws/config" do
  vars({ plugin_fragments: _aws_fragments })
end

Dir.glob(File.expand_path("../files/bin/*", __FILE__)) do |bin|
  link File.join(node[:userhome], "bin", File.basename(bin)) do
    to bin
    user node[:username]
    force false
    action :create
  end
end
