# dotfiles

Personal computing configuration, managed with [chezmoi](https://www.chezmoi.io/).
The source state lives in `home/` (see `.chezmoiroot`).

## Bootstrap

macOS / Linux:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply gorjusborg
```

Windows (PowerShell):

```powershell
iex "&{$(irm 'https://get.chezmoi.io/ps1')} -- init --apply gorjusborg"
```

Devcontainers / Codespaces run `install.sh`, which installs mise and chezmoi
if needed and applies non-interactively, with no secrets and only the
editor/shell tools.

## Per-machine settings

`chezmoi init` asks once per machine and remembers the answers in
`~/.config/chezmoi/chezmoi.toml`:

- whether this is a work machine
- notes directory (relative to home)
- personal git SSH key; on work machines also the work SSH key, work git
  name/email, and an optional Java truststore
- KeePassXC database path (blank disables secrets), and if set, an optional
  YubiKey slot[:serial] for challenge-response (unlocks once per apply)

Re-ask with `chezmoi init --prompt`. OS, distro, WSL, and containers are
detected automatically.

Work-specific shell setup that doesn't belong in this repo goes in
`~/.work.bashrc`, which `.bashrc` sources if present.

## Secrets

Secrets come only from KeePassXC at apply time; nothing secret is committed.
`~/.secrets` (mode 0600) is rendered from KeePassXC entries and sourced by
`.bashrc`.

Enable the secret-scanning pre-commit hook in each clone you commit from:

```sh
git config core.hooksPath .githooks
```

## Tools

`~/.config/mise/config.toml` lists the tools mise manages. `chezmoi apply`
runs `mise install` whenever that list changes, and installs the `tn` Lua rock
on machines that don't have it yet. Building some tools needs a C compiler.

## Neovim plugin lock file

`lazy-lock.json` is written only when missing (`create_`), so local plugin
updates are never overwritten. To share a newer lock file:

```sh
chezmoi add --create ~/.config/nvim/lazy-lock.json
```
