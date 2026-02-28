node.reverse_merge!(
  plugins: [],
  cookbooks: ["homebrew", "tmux", "docker"],
  brew: {
    tap: [],
    packages: [
      "fish", "git", "tmux",
    ],
    cask_packages: [],
  },
)
