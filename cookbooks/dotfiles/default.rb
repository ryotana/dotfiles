define :dotfile_link do
  link File.join(node[:userhome], params[:name]) do
    to File.expand_path("../../../dotfiles/#{params[:name]}", __FILE__)
    user node[:username]
    force true
    action :create
  end
end

define :dotfile_template do
  template File.join(node[:userhome] + "/" + params[:name]) do
    source File.expand_path("../../../dotfiles/#{params[:name]}.erb", __FILE__)
    user node[:username]
  end
end
