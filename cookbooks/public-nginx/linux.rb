sysd_user = lambda do |args|
  "sudo -u #{node[:username]} XDG_RUNTIME_DIR=/run/user/$(id -u #{node[:username]}) systemctl --user #{args}"
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

execute "restart public-nginx" do
  command sysd_user.call("restart public-nginx.service")
  action :nothing
end
