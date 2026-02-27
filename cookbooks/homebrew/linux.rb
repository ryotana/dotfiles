BREW_ROOT = "/home/linuxbrew/.linuxbrew"
BREW_PRE_CMD = "export SHELL=bash && export HOMEBREW_NO_AUTO_UPDATE=1 && export HOMEBREW_NO_INSTALL_CLEANUP=1 && export MANPATH='#{BREW_ROOT}/share/man' && export INFOPATH='#{BREW_ROOT}/share/info' && export PATH='#{BREW_ROOT}/bin:$PATH'"

case node[:platform]
when "redhat", "amazon"
  execute 'yum groupinstall -y "Development Tools"' do
    not_if "rpm -qa | egrep ^gcc-"
  end
end

execute 'yes yes | bash -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"' do
  user node[:username]
  not_if "test -d /home/linuxbrew/.linuxbrew"
end

lists = `sudo -u #{node[:username]} /bin/bash -c '#{BREW_PRE_CMD} && brew list'`.split

(node[:brew][:tap] ||= []).each do |tap|
  execute "/bin/bash -c '#{BREW_PRE_CMD} && brew tap #{tap}'" do
    user node[:username]
    not_if "/bin/bash -c '#{BREW_PRE_CMD} && brew tap | grep #{tap}'"
  end
end

(node[:brew][:packages] ||= []).each do |pkg|
  execute "/bin/bash -c '#{BREW_PRE_CMD} && brew install #{pkg}'" do
    user node[:username]
    not_if { lists.include?(pkg) }
  end
end

(node[:brew][:cask_packages] ||= []).each do |cask|
  execute "/bin/bash -c '#{BREW_PRE_CMD} && brew install --cask #{cask}'" do
    user node[:username]
    not_if { lists.include?(cask.split("/").last) }
  end
end
