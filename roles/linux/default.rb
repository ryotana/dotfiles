%w[
  .bashrc
  .config/fish/conf.d/anyenv.fish
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
