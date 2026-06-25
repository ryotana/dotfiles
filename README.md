# dotfiles

mitamae-based dotfiles for macOS (darwin) and Amazon Linux 2023 (amazon).

mitamae: https://github.com/itamae-kitchen/mitamae

## Requirements

- `sudo`
- `git`, `curl`, `jq`
- The mitamae binary is downloaded automatically by `bin/mitamae` on first run.

## Setup

```
# create a host node file from the sample
cp nodes/sample-hostname.rb nodes/$(hostname).rb

# edit it (plugins / cookbooks to enable, brew packages, anyenv envs, ...)
vim nodes/$(hostname).rb
```

## Run

```
# dry-run (preview changes; default)
sudo ./run.sh

# apply
sudo ./run.sh -x
```

`sudo` is required; the target user is taken from `$SUDO_USER`.

## Sync

```
# git pull/push this repo and each plugins/* repo
./sync.sh
```

## Layout

- `lib/bootstrap.rb` — entry point: helper methods and the load sequence
- `nodes/` — attribute definitions only (per platform / per hostname)
- `roles/` — recipes that create resources (`common`, `darwin`, `linux`)
- `cookbooks/` — reusable units (`dotfiles`, `homebrew`, `anyenv`, `tmux`, `docker`, `public-nginx`)
- `dotfiles/` — files linked/generated under `$HOME`
- `plugins/` — environment-specific config (git-ignored; managed as separate repos)

## Plugins

Per-environment configuration is separated into `plugins/<name>/`, enabled via the
`node[:plugins]` array in a host node file. `plugins/*` and host node files are git-ignored.

**This repository is public — keep any customer/company-specific configuration in a separate
private repository.**

See [CLAUDE.md](CLAUDE.md) for architecture details.
