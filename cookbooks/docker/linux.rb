case node[:platform]
when "amazon"
  # LinuxはAL2023のみサポートする
else
  raise "#{node[:platform]} not implemented"
end

execute "install-docker" do
  command "dnf install -y docker"
  not_if "rpm -q docker"
end

service "docker" do
  action %i[start enable]
end

execute "gpasswd -a #{node[:username]} docker" do
  not_if "id #{node[:username]} | grep docker"
end

# docker CLI plugins (compose / buildx)
cli_plugins = "/usr/libexec/docker/cli-plugins"
directory cli_plugins do
  owner "root"
  group "root"
  mode "0755"
end

compose_ver = "5.1.4"
execute "install-docker-compose" do
  command <<~BASH
    curl -fsSL https://github.com/docker/compose/releases/download/v#{compose_ver}/docker-compose-linux-x86_64 \
      -o #{cli_plugins}/docker-compose && chmod +x #{cli_plugins}/docker-compose
  BASH
  not_if "#{cli_plugins}/docker-compose version --short 2>/dev/null | grep -q '^#{compose_ver}'"
end

buildx_ver = "0.35.0"
execute "install-docker-buildx" do
  command <<~BASH
    curl -fsSL https://github.com/docker/buildx/releases/download/v#{buildx_ver}/buildx-v#{buildx_ver}.linux-amd64 \
      -o #{cli_plugins}/docker-buildx && chmod +x #{cli_plugins}/docker-buildx
  BASH
  not_if "#{cli_plugins}/docker-buildx version 2>/dev/null | grep -q 'v#{buildx_ver}'"
end

%w[docker-prune.service docker-prune.timer].each do |unit|
  remote_file "/etc/systemd/system/#{unit}" do
    source File.expand_path("../files/etc/systemd/system/#{unit}", __FILE__)
    owner "root"
    group "root"
    mode "0644"
    notifies :run, "execute[apply docker-prune.timer]"
  end
end

execute "apply docker-prune.timer" do
  command "systemctl daemon-reload && systemctl reenable docker-prune.timer && systemctl restart docker-prune.timer"
  action :nothing
end
