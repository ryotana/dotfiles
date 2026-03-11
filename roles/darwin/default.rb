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
