# env
set -x LANG 'en_US.UTF-8'
set -x EDITOR 'vim'
set -x VISUAL 'vim'
set -x PAGER 'less'

set -x DOCKER_BUILDKIT 1
set -x HOMEBREW_NO_AUTO_UPDATE 1
set -x HOMEBREW_NO_INSTALL_CLEANUP 1

# alias
alias rsync='ionice -c 2 -n 7 nice -n 19 rsync --bwlimit=10250' # 100Mbps
alias less='less -R'
alias g='git'
alias gs='git status'
alias rg='rg --hidden'

# path
fish_add_path $HOME/bin
fish_add_path $HOME/.local/bin

# prompt
set fish_prompt_pwd_dir_length 4
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch yellow
set __fish_git_prompt_color_upstream_ahead green
set __fish_git_prompt_color_upstream_behind red
set __fish_git_prompt_char_dirtystate '!'
set __fish_git_prompt_char_stagedstate '~'
set __fish_git_prompt_char_untrackedfiles '?'
set __fish_git_prompt_char_stashstate '@'
set __fish_git_prompt_char_upstream_ahead '+'
set __fish_git_prompt_char_upstream_behind '-'

# fzf
set -U FZF_LEGACY_KEYBINDINGS 0
set -U FZF_REVERSE_ISEARCH_OPTS "--reverse --height=100%"

## history
function fzf_reverse_isearch
  history merge
  history | fzf --reverse --height=100% | read select
  [ -n "$select" ]; and commandline --insert -- "$select"
  commandline -f repaint
end

## ghq
function fzf_ghq_repo
  ghq list --full-path | fzf --reverse --height=100% | read select
  [ -n "$select" ]; and cd "$select"
  commandline -f repaint
end

## key_bind
function fish_user_key_bindings
  bind \cq fzf_ghq_repo
  bind \cr fzf_reverse_isearch
  bind \cu fzf_get_hosts
  bind -e \cg # tmux prefix
end
