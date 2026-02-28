case node[:platform]
when "amazon"
  execute "dnf -y install docker" do
    not_if "rpm -qa | grep docker"
  end
  execute "systemctl enable docker" do
    not_if "systemctl status docker | grep enabled"
  end
else
  raise "#{node[:platform]} not implemented"
end

execute "gpasswd -a #{node[:username]} docker" do
  not_if "id #{node[:username]} | grep docker"
end
