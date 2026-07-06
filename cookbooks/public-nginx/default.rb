# docker engine（darwin は Docker Desktop）を導入
include_cookbook "docker"

app_dir = "#{node[:userhome]}/apps/public-nginx"
www_dir = "/var/www/public"

# 配信ルート・symlink
directory www_dir do
  owner node[:username]
  group node[:usergroup]
  mode "0775"
end

# darwin は大文字小文字非区別FSのため ~/public が既定の ~/Public と衝突する
link_name = node[:is_darwin] ? "public-www" : "public"
link "#{node[:userhome]}/#{link_name}" do
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
    notifies :run, "execute[restart public-nginx]"
  end
end

# サービス化（darwin: launchd / linux: systemd --user）
if node[:is_darwin]
  include_recipe "./darwin"
else
  include_recipe "./linux"
end
