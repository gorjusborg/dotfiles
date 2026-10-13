#!/bin/sh
# Bootstrap for devcontainers / Codespaces, which run install.sh from the
# root of the cloned dotfiles repo.
set -eu

bin_dir="$HOME/.local/bin"
export PATH="$bin_dir:$PATH"

if ! command -v mise >/dev/null 2>&1; then
  curl -fsSL https://mise.run | MISE_INSTALL_PATH="$bin_dir/mise" sh
fi

if ! chezmoi="$(command -v chezmoi)"; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$bin_dir"
  chezmoi="$bin_dir/chezmoi"
fi

script_dir="$(cd "$(dirname "$0")" && pwd)"
exec "$chezmoi" init --apply --promptDefaults --source="$script_dir"
