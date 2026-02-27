node.reverse_merge!(
  hostname: `hostname`.chomp,
  username: ENV["SUDO_USER"],
  usergroup: node[:is_linux] ? ENV["SUDO_USER"] : "staff",
  userhome: node[:is_linux] ? node[:user][ENV["SUDO_USER"]]["directory"] : ENV["HOME"],
)
