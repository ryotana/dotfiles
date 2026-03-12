#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

pull_repo() {
    local dir=$1

    cd "$dir" || return 1

    if ! git fetch 2>/dev/null; then
        echo "[ERROR] $dir: Fetch failed"
        return 1
    fi

    if ! git rev-parse --abbrev-ref @{u} >/dev/null 2>&1; then
        echo "[SKIP] $dir: No upstream branch"
        return 0
    fi

    if git merge-tree --write-tree HEAD @{u} >/dev/null 2>&1; then
        echo "[PULL] $dir"
        git pull --quiet
    else
        echo "[CONFLICT] $dir: Skipping pull"
        return 0
    fi

    if [ "$(git rev-list @{u}..HEAD --count)" -gt 0 ]; then
        echo "[PUSH] $dir"
        git push --quiet
    else
        echo "[SKIP] $dir: Nothing to push"
    fi
}

pull_repo "$DOTFILES_DIR"

for plugin_dir in "$DOTFILES_DIR"/plugins/*/; do
    [ -d "$plugin_dir/.git" ] && pull_repo "$plugin_dir"
done
