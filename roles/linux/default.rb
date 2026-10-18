_aws_fragments = plugin_fragments(".aws/config.linux.d")
dotfile_template ".aws/config" do
  vars({ plugin_fragments: _aws_fragments })
end

%w[
  .bashrc
  .config/ecsta
  .config/fish/conf.d/anyenv.fish
  .config/fish/conf.d/kubernetes.fish
  .config/fish/conf.d/terraform.fish
].each do |link|
  dotfile_link link
end

Dir.glob(File.expand_path("../files/bin/*", __FILE__)) do |bin|
  link File.join(node[:userhome], "bin", File.basename(bin)) do
    to bin
    user node[:username]
    force false
    action :create
  end
end

lltsv_ver = "0.7.0"
unless node[:is_arm]
  execute "install-lltsv" do
    command <<~BASH
      curl -fsSL https://github.com/sonots/lltsv/releases/download/v#{lltsv_ver}/lltsv_linux_amd64 \
        -o #{node[:userhome]}/bin/lltsv && chmod +x #{node[:userhome]}/bin/lltsv
    BASH
    user node[:username]
    not_if "test -x #{node[:userhome]}/bin/lltsv"
  end
end

# cloud-init
%w[
  001_create_tmpdir.sh
  101_create_swap.sh
].each do |boot|
  remote_file "/var/lib/cloud/scripts/per-boot/#{boot}" do
    source File.expand_path("../files/var/lib/cloud/scripts/per-boot/#{boot}", __FILE__)
    mode "755"
  end
end

# swap-safe flush timer
template "/etc/systemd/system/swap-safe-flush.service" do
  source File.expand_path("../templates/etc/systemd/system/swap-safe-flush.service.erb", __FILE__)
  variables(swap_safe: File.expand_path("../files/bin/swap-safe", __FILE__))
  owner "root"
  group "root"
  mode "0644"
  notifies :run, "execute[apply swap-safe-flush.timer]"
end

remote_file "/etc/systemd/system/swap-safe-flush.timer" do
  source File.expand_path("../files/etc/systemd/system/swap-safe-flush.timer", __FILE__)
  owner "root"
  group "root"
  mode "0644"
  notifies :run, "execute[apply swap-safe-flush.timer]"
end

execute "apply swap-safe-flush.timer" do
  command "systemctl daemon-reload && systemctl reenable swap-safe-flush.timer && systemctl restart swap-safe-flush.timer"
  action :nothing
end
