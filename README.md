# dotsync

Keep your **git and shell configuration in sync across every machine** using a
Git repository and symbolic links.

The idea is simple and battle-tested:

1. Store your dotfiles (`.gitconfig`, `.gitignore_global`, shell aliases, …) in a
   Git repository.
2. **Symlink** them into your `$HOME` instead of copying. Because they're links,
   editing `~/.gitconfig` edits the file *in the repo* — so committing and pushing
   your changes is all it takes to back them up and share them.
3. On a new machine, clone the repo and re-create the links. You're instantly at
   home.

This repo is both a **ready-to-use template** you can fork and fill with your own
config, and a small **CLI (`git-config-sync`)** that automates the clone / link /
push / pull cycle.

---

## Table of contents

- [Why symlinks?](#why-symlinks)
- [Repository layout](#repository-layout)
- [Quick start](#quick-start)
- [Making it your own](#making-it-your-own)
- [CLI reference](#cli-reference)
- [What's inside the config](#whats-inside-the-config)
  - [Git aliases](#git-aliases)
  - [Shell aliases](#shell-aliases)
  - [Global gitignore](#global-gitignore)
  - [npm security defaults](#npm-security-defaults)
- [Security notes](#security-notes)
- [Manual usage (no CLI)](#manual-usage-no-cli)
- [Uninstall](#uninstall)
- [References](#references)

---

## Why symlinks?

Copying dotfiles means every edit has to be copied *back* into the repo by hand —
it drifts out of date immediately. A symlink makes `~/.gitconfig` and
`repo/config/gitconfig` **the same file**:

```
~/.gitconfig ──symlink──▶ ~/DEVELOPMENT/dotfiles/config/gitconfig  (tracked by git)
```

Edit either path, `git commit && git push`, and every other machine gets the
change on its next `pull`.

---

## Repository layout

```
git-config-sync/
├── bin/
│   └── git-config-sync      # the CLI (bash, no dependencies)
├── config/
│   ├── gitconfig            # → ~/.gitconfig
│   ├── gitignore_global     # → ~/.gitignore_global
│   └── bashrc.aliases       # appended to ~/.bashrc (not symlinked)
├── scripts/
│   └── secure-packages.sh   # optional npm hardening
├── sync.map                 # manifest: which file links where
├── install.sh               # one-shot installer for this template
├── AGENTS.md                # guidance for AI coding agents
├── CONTRIBUTING.md          # how to contribute
└── README.md
```

`sync.map` is the source of truth for what gets linked. Each line maps a repo
file to a destination under `$HOME`:

```
config/gitconfig          .gitconfig
config/gitignore_global   .gitignore_global
```

Add your own lines to sync more files (e.g. `config/tmux.conf  .tmux.conf`).

---

## Quick start

```bash
# 1. Clone this template (or your fork of it)
git clone https://github.com/adonyssantos/git-config-sync.git ~/DEVELOPMENT/dotfiles
cd ~/DEVELOPMENT/dotfiles

# 2. Run the installer — it installs the CLI, creates the symlinks,
#    appends the shell aliases, and optionally hardens npm.
bash install.sh

# 3. Load the new aliases and set your identity
source ~/.bashrc
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

`install.sh` backs up anything it would overwrite as `<file>.bak`, so it's safe to
run on a machine that already has a `~/.gitconfig`.

---

## Making it your own

1. **Fork** this repository on GitHub (or just push it to a new repo of your own).
2. Replace the placeholder values in `config/gitconfig` (`[user]`, `[github]`) —
   or leave them and set your identity with `git config --global` as shown above.
3. Drop your own dotfiles into `config/` and add a line to `sync.map` for each.
4. Commit and push. From then on:

   ```bash
   git-config-sync push "add tmux config"   # commit + push your changes
   git-config-sync pull                      # on another machine: pull + re-link
   ```

On every new machine you only need:

```bash
git-config-sync init https://github.com/<you>/<your-dotfiles>.git
git-config-sync link
```

---

## CLI reference

Once installed, `git-config-sync` is on your `PATH` (via `~/.local/bin`). It
remembers which repository is your "config repo" in
`~/.config/git-config-sync/state`.

| Command | Description |
|---------|-------------|
| `git-config-sync init <repo-url> [dir]` | Clone your config repo (default dir `~/DEVELOPMENT/dotfiles`) and remember it |
| `git-config-sync use <dir>` | Point the CLI at an existing local clone |
| `git-config-sync link` | Create the symlinks from `sync.map` and append the shell aliases |
| `git-config-sync unlink` | Remove the symlinks and the alias block (restores any `.bak` backups) |
| `git-config-sync push [message]` | `git add -A`, commit, and push in the config repo |
| `git-config-sync pull` | `git pull --ff-only`, then re-link |
| `git-config-sync status` | Show `git status` for the config repo |
| `git-config-sync where` | Print the resolved config repo path |
| `git-config-sync help` | Show usage |

**How the active repo is resolved** (first match wins):

1. `$GIT_CONFIG_SYNC_DIR` environment variable
2. the path saved by `init` / `use`
3. the repository the `git-config-sync` script itself lives in (if it has a `sync.map`)

---

## What's inside the config

### Git aliases

Defined in `config/gitconfig`. Use as `git <alias>`, e.g. `git st`, `git lg`.

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `cg` | `config --global` | Edit global git config |
| `cl` | `config --list` | List all effective config values |
| `all` | `add .` | Stage all changes |
| `st` | `status` | Working tree status |
| `unstage` | `reset HEAD --` | Unstage files (keep changes) |
| `ci` | `commit -m` | Commit with a message |
| `aci` | `add . && commit -m` | Stage everything, then commit |
| `cia` | `commit -am` | Stage tracked files and commit |
| `amend` | `commit --amend` | Amend the last commit |
| `ps` | `push` | Push |
| `psu` | `push --set-upstream origin <branch>` | Push and set upstream |
| `psf` | `push --force` | Force push (careful) |
| `pl` | `pull` | Pull |
| `pf` | `pull && fetch` | Pull then fetch all remotes |
| `ud <ref>` | `fetch && rebase <ref>` | Fetch and rebase onto a ref |
| `udm` | `ud origin/main` | Update branch from `origin/main` |
| `co` | `checkout` | Switch branches / restore files |
| `br` | `branch` | List / manage branches |
| `main` | `branch -M main` | Rename current branch to `main` |
| `back` | `checkout -- .` | Discard all working-tree changes |
| `lg` | pretty graph log | Compact colorized commit graph |
| `nm` | `lg --no-merges` | Graph log without merges |
| `df` | `lg -p` | Graph log with inline diffs |

### Shell aliases

Defined in `config/bashrc.aliases`, appended to `~/.bashrc`.

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `..` | `cd ..` | Up one directory |
| `...` | `cd ../..` | Up two directories |
| `dev` | `mkdir -p ~/DEVELOPMENT && cd ~/DEVELOPMENT` | Jump to the dev folder |
| `open` | `explorer.exe` | Open in Windows Explorer (**WSL only**, auto-detected) |
| `dc` | `docker compose` | Docker Compose shorthand |
| `dps` | `docker ps` | Running containers |
| `dpa` | `docker ps -a` | All containers |
| `update` | package-manager upgrade | Update system packages (auto-detects apt/dnf/yum/pacman/zypper/apk) |
| `dropcache` | `echo 1 \| sudo tee /proc/sys/vm/drop_caches` | Free the Linux page cache |
| `duh` | `du -h --max-depth=1 \| sort -hr` | Disk usage, sorted |

### Global gitignore

`config/gitignore_global` is a broad ignore list (Linux, macOS, Windows, Vim,
VS Code, Visual Studio) wired up via `core.excludesfile = ~/.gitignore_global`.
It keeps OS and editor cruft out of every repo without per-project `.gitignore`
edits.

### npm security defaults

`scripts/secure-packages.sh` writes an `~/.npmrc` with:

- `save-exact = true` — pin exact versions, no `^`/`~` ranges
- `min-release-age = 7d` — refuse packages published in the last 7 days
- `ignore-scripts = true` — don't run install lifecycle scripts

Together these shrink the window and blast radius of npm supply-chain attacks.

---

## Security notes

- **`ignore-scripts = true`** can break packages that build on install (native
  addons, etc.). Run `npm rebuild` or install those with `--foreground-scripts`
  when needed.
- **`core.hooksPath = /dev/null`** is included in `config/gitconfig` but
  **commented out**. Enabling it disables *all* git hooks globally, which blocks
  malicious hooks shipped in a cloned repo — but also disables legitimate tools
  like husky, pre-commit and lefthook. Enable it only if you understand the
  trade-off.

---

## Manual usage (no CLI)

You don't need the CLI — the whole thing is just symlinks:

```bash
# Linux / macOS
ln -sf ~/DEVELOPMENT/dotfiles/config/gitconfig        ~/.gitconfig
ln -sf ~/DEVELOPMENT/dotfiles/config/gitignore_global ~/.gitignore_global
```

```powershell
# Windows (PowerShell as Administrator, or with Developer Mode enabled)
New-Item -ItemType SymbolicLink -Path $HOME\.gitconfig `
         -Target $HOME\DEVELOPMENT\dotfiles\config\gitconfig
```

Then commit and push from the repo as usual.

---

## Uninstall

```bash
git-config-sync unlink          # remove symlinks + alias block, restore backups
rm ~/.local/bin/git-config-sync # remove the CLI shim
```

---

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for how to set
up, test against a throwaway `$HOME`, and open a pull request. AI agents should
also read [AGENTS.md](AGENTS.md).

---

## References

- [`ln` — create links](http://manpages.ubuntu.com/manpages/xenial/man1/ln.1.html)
- [`mklink` — Windows symbolic links](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/mklink)
- [git config documentation](https://git-scm.com/docs/git-config)
