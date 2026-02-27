is_arm = `uname -m`.chomp == "arm64"

node.reverse_merge!(
  is_darwin: true,
  is_arm: is_arm,
)
