define :dotfile_link, source: nil do
  dotfiles_dir = params[:source] || File.expand_path("../../../dotfiles", __FILE__)
  link File.join(node[:userhome], params[:name]) do
    to File.join(dotfiles_dir, params[:name])
    user node[:username]
    force true
    action :create
  end
end

define :dotfile_template, vars: {} do
  template File.join(node[:userhome] + "/" + params[:name]) do
    source File.expand_path("../../../dotfiles/#{params[:name]}.erb", __FILE__)
    owner node[:username]
    group node[:usergroup]
    variables params[:vars] unless params[:vars].empty?
  end
end
