node.reverse_merge!(
  plugins: ["ei"],
  cookbooks: ["homebrew", "tmux"],
  brew: {
    tap: ["daipeihust/tap"],
    packages: [
      "eza", "gawk", "ripgrep", "diff-so-fancy",
      "git", "git-lfs", "gitleaks", "tig", "ghq",
      "font-hackgen-nerd", "im-select", "fish", "fzf",
      "awscli",
    ],
    cask_packages: ["karabiner-elements", "google-japanese-ime", "alfred", "bartender", "session-manager-plugin", "alacritty", "1password", "firefox", "vivaldi", "notion", "notion-calendar", "visual-studio-code", "claude", "finicky"],
  },
)
