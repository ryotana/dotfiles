# Docker Desktop が起動していないと compose up は失敗するが、
# KeepAlive + ThrottleInterval により起動後に自動リトライされる
launch_agents = "#{node[:userhome]}/Library/LaunchAgents"
uid = "$(id -u #{node[:username]})"
launchctl_user = lambda do |args|
  "sudo -u #{node[:username]} launchctl #{args}"
end

directory launch_agents do
  owner node[:username]
  group node[:usergroup]
end

remote_file "#{launch_agents}/local.public-nginx.plist" do
  source File.expand_path("../files/local.public-nginx.plist", __FILE__)
  owner node[:username]
  group node[:usergroup]
  mode "0644"
  notifies :run, "execute[restart public-nginx]"
end

execute "enable local.public-nginx" do
  command launchctl_user.call("bootstrap gui/#{uid} #{launch_agents}/local.public-nginx.plist")
  not_if "#{launchctl_user.call("print gui/#{uid}/local.public-nginx")} >/dev/null 2>&1"
end

execute "restart public-nginx" do
  command "#{launchctl_user.call("bootout gui/#{uid}/local.public-nginx")} 2>/dev/null; #{launchctl_user.call("bootstrap gui/#{uid} #{launch_agents}/local.public-nginx.plist")}"
  action :nothing
end
