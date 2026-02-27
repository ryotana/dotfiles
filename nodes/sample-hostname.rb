node.reverse_merge!(
  plugins: [],
  cookbooks: ["homebrew"],
  brew: {
    tap: [],
    packages: [
      "fish", "git",
    ],
    cask_packages: [],
  },
)
