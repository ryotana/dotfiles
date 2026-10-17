case node[:platform]
when "amazon"
  # LinuxはAL2023のみサポートする
else
  raise "#{node[:platform]} not implemented"
end

execute "install-zram-generator" do
  command "dnf install -y zram-generator"
  not_if "rpm -q zram-generator"
end

remote_file "/etc/systemd/zram-generator.conf" do
  source File.expand_path("../files/etc/systemd/zram-generator.conf", __FILE__)
  owner "root"
  group "root"
  mode "0644"
  notifies :run, "execute[apply zram0]"
end

execute "apply zram0" do
  command "systemctl daemon-reload && systemctl restart systemd-zram-setup@zram0.service"
  action :nothing
end

remote_file "/etc/sysctl.d/99-zram.conf" do
  source File.expand_path("../files/etc/sysctl.d/99-zram.conf", __FILE__)
  owner "root"
  group "root"
  mode "0644"
  notifies :run, "execute[apply 99-zram.conf]"
end

execute "apply 99-zram.conf" do
  command "sysctl -p /etc/sysctl.d/99-zram.conf"
  action :nothing
end
