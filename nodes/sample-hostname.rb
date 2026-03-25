node.reverse_merge!(
  plugins: ["ei"],
  cookbooks: ["homebrew", "tmux", "docker", "anyenv"],
  brew: {
    tap: [],
    packages: [
      "fish", "git", "tmux", "eza", "diff-so-fancy", "colordiff", "parallel",
      "direnv", "ripgrep", "fd", "fzf", "ast-grep", "scc", "sd",
      "jq", "jo", "yq",
      "shellcheck", "yamllint", "actionlint",
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
