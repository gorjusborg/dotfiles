#!/bin/sh
# Bootstrap for devcontainers / Codespaces, which run install.sh from the
# root of the cloned dotfiles repo.
set -eu

bin_dir="$HOME/.local/bin"
if ! chezmoi="$(command -v chezmoi)"; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$bin_dir"
  chezmoi="$bin_dir/chezmoi"
fi

script_dir="$(cd "$(dirname "$0")" && pwd)"
exec "$chezmoi" init --apply --promptDefaults --source="$script_dir"
