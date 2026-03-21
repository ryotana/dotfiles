_aws_fragments = plugin_fragments(".aws/config.linux.d")
dotfile_template ".aws/config" do
  vars({ plugin_fragments: _aws_fragments })
end

%w[
  .bashrc
  .config/ecsta
  .config/fish/conf.d/anyenv.fish
  .config/fish/conf.d/kubernetes.fish
  .config/fish/conf.d/terraform.fish
].each do |link|
  dotfile_link link
end

Dir.glob(File.expand_path("../files/bin/*", __FILE__)) do |bin|
  link File.join(node[:userhome], "bin", File.basename(bin)) do
    to bin
    user node[:username]
    force false
    action :create
  end
end

# cloud-init
%w[
  001_create_tmpdir.sh
  101_create_swap.sh
].each do |boot|
  remote_file "/var/lib/cloud/scripts/per-boot/#{boot}" do
    source File.expand_path("../files/var/lib/cloud/scripts/per-boot/#{boot}", __FILE__)
    mode "755"
  end
end
