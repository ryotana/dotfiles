BREW_PATH = if node[:is_arm]
    "/opt/homebrew/bin"
  else
    "/usr/local/bin"
  end
BREW_PRE_CMD = "export SHELL=bash && export HOMEBREW_NO_AUTO_UPDATE=1 && export HOMEBREW_NO_INSTALL_CLEANUP=1 && export PATH=#{BREW_PATH}:$PATH"

# Homebrew must be installed manually beforehand due to Xcode dependencies
raise "first you should install homebrew manually" unless File.exist?("#{BREW_PATH}/brew")

lists = `sudo -u #{node[:username]} #{BREW_PATH}/brew list`.split

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
