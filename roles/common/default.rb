%W[
  #{node[:userhome]}/bin
  #{node[:userhome]}/repos
  #{node[:userhome]}/.config
  #{node[:userhome]}/.config/fish
  #{node[:userhome]}/.config/fish/conf.d
].each do |dir|
  directory dir do
    owner node[:username]
    group node[:usergroup]
  end
end

include_cookbook "dotfiles"

%w[
  .config/fish/config.fish
  .config/fish/functions
].each do |link|
  dotfile_link link
end
