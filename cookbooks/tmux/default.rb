TPM_REPO = "https://github.com/tmux-plugins/tpm"

%W[
  #{node[:userhome]}/.tmux
  #{node[:userhome]}/.tmux/plugins
].each do |dir|
  directory dir do
    owner node[:username]
    group node[:usergroup]
  end
end

git "clone tpm" do
  user node[:username]
  repository TPM_REPO
  destination "#{node[:userhome]}/.tmux/plugins/tpm"
end

template File.join(node[:userhome] + "/.tmux.conf") do
  source File.expand_path("../templates/tmux.conf.erb", __FILE__)
end

file File.join(node[:userhome] + "/.tmux.conf") do
  mode "0644"
  owner node[:username]
  group node[:usergroup]
end

Dir.glob(File.expand_path("../files/bin/*", __FILE__)) do |bin|
  link File.join(node[:userhome], "bin", File.basename(bin)) do
    to bin
    user node[:username]
    force false
    action :create
  end
end
