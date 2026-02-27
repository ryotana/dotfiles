node.reverse_merge!(
  plugins: [],
  cookbooks: ["homebrew", "tmux"],
  brew: {
    tap: [],
    packages: [
      "fish", "git", "tmux",
    ],
    cask_packages: [],
  },
)
