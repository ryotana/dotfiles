ANYENV_REPO = "https://github.com/anyenv/anyenv.git"
ANYENV_ROOT = "#{node[:userhome]}/.anyenv"
ANYENV_PRE_CMD = "export SHELL=bash && export ANYENV_ROOT=\"#{ANYENV_ROOT}\" && export PATH=\"#{ANYENV_ROOT}/bin:$PATH\""

git "clone anyenv" do
  user node[:username]
  repository ANYENV_REPO
  destination ANYENV_ROOT
end

execute "/bin/bash -c '#{ANYENV_PRE_CMD} && yes | anyenv install --init'" do
  user node[:username]
  not_if "test -d #{node[:userhome]}/.config/anyenv/anyenv-install"
end

(node[:anyenv][:plugins] ||= []).each do |name, repo|
  git "clone anyenv plugin: #{name}" do
    user node[:username]
    repository repo
    destination "#{ANYENV_ROOT}/plugins/#{name}"
  end
end

(node[:anyenv][:envs] ||= []).each do |env|
  execute "/bin/bash -c '#{ANYENV_PRE_CMD} && eval \"$(anyenv init - bash)\" && anyenv install #{env}'" do
    user node[:username]
    not_if "test -d #{ANYENV_ROOT}/envs/#{env}"
  end
end
