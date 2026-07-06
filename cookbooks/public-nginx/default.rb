case node[:platform]
when "amazon"
  # docker engine は cookbooks/docker で導入済み前提
else
  raise "#{node[:platform]} not implemented"
end

app_dir = "#{node[:userhome]}/apps/public-nginx"
www_dir = "/var/www/public"
sysd_user = lambda do |args|
  "sudo -u #{node[:username]} XDG_RUNTIME_DIR=/run/user/$(id -u #{node[:username]}) systemctl --user #{args}"
end

# 配信ルート・symlink
directory www_dir do
  owner node[:username]
  group node[:usergroup]
  mode "0775"
end

link "#{node[:userhome]}/public" do
  to www_dir
  user node[:username]
  force false
end

# コンテナ内の nginx worker (uid 101) が PUT で書き込むため 0777
directory File.join(www_dir, "uploads") do
  owner node[:username]
  group node[:usergroup]
  mode "0777"
end

["#{node[:userhome]}/apps", app_dir].each do |dir|
  directory dir do
    owner node[:username]
    group node[:usergroup]
  end
end

%w[docker-compose.yml default.conf upload.html].each do |f|
  remote_file File.join(app_dir, f) do
    source File.expand_path("../files/#{f}", __FILE__)
    owner node[:username]
    group node[:usergroup]
    mode "0644"
    notifies :run, "execute[restart public-nginx.service]"
  end
end

execute "enable-linger #{node[:username]}" do
  command "loginctl enable-linger #{node[:username]}"
  not_if "loginctl show-user #{node[:username]} | grep -q Linger=yes"
end

directory "#{node[:userhome]}/.config/systemd/user" do
  owner node[:username]
  group node[:usergroup]
end

remote_file "#{node[:userhome]}/.config/systemd/user/public-nginx.service" do
  source File.expand_path("../files/public-nginx.service", __FILE__)
  owner node[:username]
  group node[:usergroup]
  mode "0644"
  notifies :run, "execute[public-nginx daemon-reload]", :immediately
end

execute "public-nginx daemon-reload" do
  command sysd_user.call("daemon-reload")
  action :nothing
end

execute "enable public-nginx.service" do
  command sysd_user.call("enable --now public-nginx.service")
  not_if sysd_user.call("is-enabled --quiet public-nginx.service")
end

execute "restart public-nginx.service" do
  command sysd_user.call("restart public-nginx.service")
  action :nothing
end
