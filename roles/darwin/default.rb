%W[
  #{node[:userhome]}/tmp
  #{node[:userhome]}/.config/karabiner
].each do |dir|
  directory dir do
    owner node[:username]
    group node[:usergroup]
  end
end

%w[
  .config/fish/conf.d/darwin.fish
  .config/karabiner/karabiner.json
].each do |link|
  dotfile_link link
end

_aws_fragments = plugin_fragments(".aws/config.darwin.d")
dotfile_template ".aws/config" do
  vars({ plugin_fragments: _aws_fragments })
end
