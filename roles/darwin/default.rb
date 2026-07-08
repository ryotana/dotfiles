%W[
  #{node[:userhome]}/tmp
  #{node[:userhome]}/.config/karabiner
  #{node[:userhome]}/.config/alacritty
  #{node[:userhome]}/.config/alacritty/themes
].each do |dir|
  directory dir do
    owner node[:username]
    group node[:usergroup]
  end
end

%w[
  .config/fish/conf.d/darwin.fish
  .config/karabiner/karabiner.json
  .config/alacritty/alacritty.toml
].each do |link|
  dotfile_link link
end

execute "git clone https://github.com/alacritty/alacritty-theme #{node[:userhome]}/.config/alacritty/themes" do
  user node[:username]
  not_if "test -d #{node[:userhome]}/.config/alacritty/themes/.git"
end

_aws_fragments = plugin_fragments(".aws/config.darwin.d")
dotfile_template ".aws/config" do
  vars({ plugin_fragments: _aws_fragments })
end

_finicky_fragments = plugin_fragments(".finicky.d")
_finicky_rewrite_fragments = plugin_fragments(".finicky.rewrite.d")
dotfile_template ".finicky.js" do
  vars({ plugin_fragments: _finicky_fragments, rewrite_fragments: _finicky_rewrite_fragments })
end
