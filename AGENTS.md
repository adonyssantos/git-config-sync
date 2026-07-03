# AGENTS.md

Guidance for AI coding agents (Claude Code, Cursor, Copilot, Aider, …) working in
this repository. Humans: see [README.md](README.md).

## What this project is

`dotsync` syncs a user's git/shell dotfiles across machines via a Git repo
and symbolic links. It ships:

- `bin/dotsync` — a dependency-free bash CLI (the core logic).
- `config/` — the dotfiles that get symlinked into `$HOME`.
- `sync.map` — the manifest mapping `config/*` files to `$HOME` targets.
- `install.sh` — an installer (works via `curl | bash` or from a local clone).
- `scripts/secure-packages.sh` — optional npm hardening.

## Golden rules

1. **Never commit real personal data.** No real names, emails, tokens, SSH keys,
   API keys, hostnames, or machine-specific paths. Config files must ship with
   placeholders (`Your Name`, `you@example.com`, `your-username`).
2. **This is a public template.** Keep everything generic and portable. Prefer
   feature-detection (`command -v foo`) over hardcoding tools or OSes.
3. **Symlink, never copy.** The whole value proposition is that edits flow back
   into the repo. Don't replace `ln -s` with `cp`.
4. **Keep changes idempotent.** `link`, `unlink`, and `install.sh` must be safe to
   run repeatedly. Back up before overwriting; restore on unlink.
5. **No new runtime dependencies.** The CLI is intentionally plain bash so it runs
   anywhere. Don't introduce Node, Python, or package managers to run it.

## Conventions

- Bash scripts start with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Use the existing `info`/`ok`/`warn`/`die` helpers in the CLI for output.
- Adding a new synced dotfile = add the file under `config/` **and** a line to
  `sync.map`. Files appended to an rc file (not symlinked, like `bashrc.aliases`)
  use `BEGIN`/`END` markers so they can be cleanly removed.
- Document any new alias in the README tables and any new command in the CLI
  reference table.

## Before you finish

Run these checks and make sure they pass:

```bash
bash -n bin/dotsync install.sh scripts/secure-packages.sh   # syntax
shellcheck bin/dotsync install.sh scripts/secure-packages.sh # if available

# End-to-end smoke test against a throwaway HOME (never your real one):
TMP="$(mktemp -d)"
HOME="$TMP" DOTSYNC_DIR="$PWD" bash bin/dotsync link
HOME="$TMP" DOTSYNC_DIR="$PWD" bash bin/dotsync doctor
HOME="$TMP" DOTSYNC_DIR="$PWD" bash bin/dotsync unlink
rm -rf "$TMP"
```

## Things to watch out for

- `link`/`unlink` operate on the user's `$HOME`. Always test with an overridden
  `HOME` pointing at a temp dir — never against the real home directory.
- `install.sh` and the CLI write to `~/.bashrc`, `~/.gitconfig`, `~/.npmrc`, and
  `~/.config/`. Treat these as user-owned; back up and be reversible.
- The `update` and `dropcache` shell aliases use `sudo`. Don't add `sudo` to code
  paths that run automatically.
