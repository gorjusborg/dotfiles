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

Devcontainers / Codespaces run `install.sh`, which applies non-interactively
with no secrets.

`chezmoi init` asks a few questions per machine. Re-ask with
`chezmoi init --prompt`.

## Secrets

Secrets come only from KeePassXC at apply time; nothing secret is committed.
Leaving the KeePassXC database path blank on `chezmoi init` disables secrets
on that machine.

Enable the secret-scanning pre-commit hook in each clone you commit from:

```sh
git config core.hooksPath .githooks
```

## Neovim plugin lock file

`lazy-lock.json` is written only when missing (`create_`), so local plugin
updates are never overwritten. To share a newer lock file:

```sh
chezmoi add --create ~/.config/nvim/lazy-lock.json
```
