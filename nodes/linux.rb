is_arm = `uname -m`.chomp == "aarch64"

node.reverse_merge!(
  is_linux: true,
  is_arm: is_arm,
)
