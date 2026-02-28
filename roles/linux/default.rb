%w[
  .bashrc
  .config/fish/conf.d/anyenv.fish
].each do |link|
  dotfile_link link
end
