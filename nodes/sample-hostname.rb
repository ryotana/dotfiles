node.reverse_merge!(
  plugins: [],
  cookbooks: ["homebrew", "tmux", "docker", "anyenv"],
  brew: {
    tap: [],
    packages: [
      "fish", "git", "tmux",
      "percona-toolkit", "pgbadger",
    ],
    cask_packages: [],
  },
  anyenv: {
    plugins: {
      'anyenv-update': "https://github.com/znz/anyenv-update.git",
      'anyenv-git': "https://github.com/znz/anyenv-git.git",
    },
    envs: ["rbenv", "nodenv"],
  },
)
