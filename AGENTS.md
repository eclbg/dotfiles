# Dotfiles

This repo manages configuration files for various tools. Configs are synced between the repo and the local machine using `make` commands.

## Convention

Each tool has three Makefile targets:

- `make get-<tool>` — Installs the config from the repo to the local machine. Backs up any existing config first.
- `make put-<tool>` — Copies the local config into the repo (to commit changes).
- `make diff-<tool>` — Shows the diff between the local config and the repo version.

`make get-all` runs all `get-*` targets.

## Adding a new tool

1. Create a directory for the tool (e.g., `toolname/`) and add the config file(s).
2. Add `get-<tool>`, `put-<tool>`, and `diff-<tool>` targets to the Makefile following the existing pattern:
   - `get` should `mkdir -p` the target directory, back up existing files with `[ -f <path> ] && mv --backup=numbered <path> backups/ || true`, then `cp` from repo to local.
   - `put` should `cp` from local to repo.
   - `diff` should use `-diff` (prefixed with `-` to ignore exit code) to compare local vs repo.
3. Add the new `get-<tool>` target to the `get-all` dependency list.

## Installing tools

Tools are installed via Homebrew using the `Brewfile`. Run `brew bundle --file=Brewfile`.
