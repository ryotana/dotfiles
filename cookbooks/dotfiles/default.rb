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

define :dotfile_merged_json, base: nil, overlay: nil do
  root = File.expand_path("../../..", __FILE__)
  dest = File.join(node[:userhome], params[:name])
  sources = [File.join(root, "dotfiles", params[:base])]
  sources << File.join(root, "dotfiles", params[:overlay]) if params[:overlay]
  (node[:plugins] || []).each do |plugin|
    fragment = File.join(root, "plugins", plugin, "dotfiles", params[:name])
    sources << fragment if File.exist?(fragment)
  end
  ref = run_command("test -f #{dest} && jq -e . #{dest} >/dev/null 2>&1 && echo #{dest} || echo /dev/null").stdout.strip
  jq_merge = [
    'def dedupe: reduce .[] as $i ([]; if any(.[]; . == $i) then . else . + [$i] end);',
    'def merge($a; $b):',
    'if ($a | type) == "object" and ($b | type) == "object" then reduce ($b | keys_unsorted[]) as $k ($a; .[$k] = merge(.[$k]; $b[$k]))',
    'elif ($a | type) == "array" and ($b | type) == "array" then ($a + $b) | dedupe',
    'else $b end;',
    'def reorder($ref):',
    'if type == "object" and ($ref | type) == "object" then . as $o',
    '| [$ref | keys_unsorted[] | select(. as $k | $o | has($k))] as $head',
    '| reduce ($head + ($o | keys_unsorted | map(select(. as $k | $head | index($k) == null))))[] as $k ({}; .[$k] = ($o[$k] | reorder($ref[$k])))',
    'else . end;',
    'reduce .[] as $x ({}; merge(.; $x)) | reorder($ref[0])'
  ].join(" ")
  merged = run_command("jq -s --slurpfile ref #{ref} '#{jq_merge}' #{sources.join(" ")}").stdout
  file dest do
    content merged
    owner node[:username]
    group node[:usergroup]
  end
end
