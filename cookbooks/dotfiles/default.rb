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

define :dotfile_merged_json, base: nil do
  root = File.expand_path("../../..", __FILE__)
  sources = [File.join(root, "dotfiles", params[:base])]
  (node[:plugins] || []).each do |plugin|
    fragment = File.join(root, "plugins", plugin, "dotfiles", params[:name])
    sources << fragment if File.exist?(fragment)
  end
  merged = run_command("jq -s 'reduce .[] as $x ({}; . * $x)' #{sources.join(" ")}").stdout
  file File.join(node[:userhome], params[:name]) do
    content merged
    owner node[:username]
    group node[:usergroup]
  end
end
