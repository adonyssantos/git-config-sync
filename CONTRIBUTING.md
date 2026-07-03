# Contributing to git-config-sync

Thanks for your interest in improving `git-config-sync`! This project is a small,
dependency-free bash tool plus a dotfiles template, so contributions are easy to
make and easy to review. This guide explains how.

> Using an AI coding agent? Read [AGENTS.md](AGENTS.md) too — it captures the same
> rules in a machine-friendly form.

## Ways to contribute

- **Report bugs** — open an issue with your OS/shell, the command you ran, and the
  output. A minimal reproduction is worth a thousand words.
- **Suggest features** — open an issue describing the problem before the solution.
- **Improve docs** — typo fixes, clearer wording, and better examples are always
  welcome.
- **Send code** — new CLI commands, wider OS support, new sample dotfiles.

## Ground rules

1. **Never commit personal data.** No real names, emails, tokens, SSH keys, API
   keys, hostnames, or machine-specific paths. Ship placeholders instead
   (`Your Name`, `you@example.com`, `your-username`).
2. **Keep it portable and dependency-free.** The CLI is plain bash on purpose so
   it runs anywhere. Don't add Node, Python, or other runtimes to run it. Prefer
   feature detection (`command -v foo`) over hardcoding tools or OSes.
3. **Symlink, never copy.** The whole point is that edits flow back into the repo.
4. **Stay idempotent and reversible.** `link`, `unlink`, and `install.sh` must be
   safe to run repeatedly: back up before overwriting, restore on unlink.

## Development setup

```bash
git clone https://github.com/<your-fork>/git-config-sync.git
cd git-config-sync
```

There's nothing to build. Run the CLI directly:

```bash
bash bin/git-config-sync help
```

**Always test against a throwaway `$HOME`** so you never touch your real dotfiles:

```bash
TMP="$(mktemp -d)"
HOME="$TMP" GIT_CONFIG_SYNC_DIR="$PWD" bash bin/git-config-sync link
HOME="$TMP" GIT_CONFIG_SYNC_DIR="$PWD" bash bin/git-config-sync unlink
rm -rf "$TMP"
```

## Coding conventions

- Bash scripts start with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Use the existing `info` / `ok` / `warn` / `die` helpers in the CLI for output.
- Adding a new synced dotfile = add the file under `config/` **and** a line to
  `sync.map`. Content appended to an rc file (not symlinked, like
  `bashrc.aliases`) must be wrapped in `BEGIN` / `END` markers so it can be
  removed cleanly.
- Document every change: new aliases go in the README tables, new commands go in
  the CLI reference table.

## Before you open a pull request

Make sure these pass:

```bash
# Syntax check
bash -n bin/git-config-sync install.sh scripts/secure-packages.sh

# Static analysis (if installed)
shellcheck bin/git-config-sync install.sh scripts/secure-packages.sh

# End-to-end smoke test against a throwaway HOME (see above)
```

## Pull request checklist

- [ ] No personal data added anywhere.
- [ ] Scripts pass `bash -n` (and `shellcheck` if available).
- [ ] `link` / `unlink` tested against a throwaway `$HOME`.
- [ ] Docs updated (README tables, CLI reference) for any user-facing change.
- [ ] Commits are focused and have clear messages.

## Commit messages

Write short, imperative-mood subjects (e.g. "Add `sync.map` support for nested
paths"). Keep one logical change per commit where practical.

## Reporting security issues

If you find a security problem (e.g. a code path that could leak credentials or
run untrusted code), please open an issue describing the impact and, if possible,
a fix. Since this tool touches `~/.gitconfig`, `~/.npmrc`, and `~/.bashrc`,
security-relevant changes get priority review.

## License

By contributing, you agree that your contributions are licensed under the
project's [MIT License](LICENSE).
