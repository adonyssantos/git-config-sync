#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# git-config-sync — one-shot installer for this repository.
#
# It will:
#   1. Install the `git-config-sync` CLI into ~/.local/bin
#   2. Symlink the tracked config files (see sync.map) into $HOME, backing up
#      anything already there as <file>.bak
#   3. Append the shell aliases block to your ~/.bashrc (idempotent)
#   4. Optionally apply the npm security defaults (scripts/secure-packages.sh)
#
# Re-running is safe: existing links are left untouched.
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"

echo "This installer will:"
echo "  - Install the git-config-sync CLI to $BIN_DIR"
echo "  - Symlink config files from this repo into \$HOME (backing up existing ones)"
echo "  - Append shell aliases to ~/.bashrc (safe to re-run)"
echo "  - Apply npm security defaults (optional)"
echo ""
read -r -p "Continue? (y/N) " choice
[ "$choice" = "y" ] || { echo "Aborted."; exit 1; }

# ── 1. Install the CLI ─────────────────────────────────────────────────────
chmod +x "$REPO_DIR/bin/git-config-sync"
mkdir -p "$BIN_DIR"
ln -sf "$REPO_DIR/bin/git-config-sync" "$BIN_DIR/git-config-sync"
echo "==> Installed CLI: $BIN_DIR/git-config-sync"
case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) echo "  ! $BIN_DIR is not on your PATH. Add this to your shell rc:"
       echo "        export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac

# ── 2 & 3. Link config files + aliases ─────────────────────────────────────
GIT_CONFIG_SYNC_DIR="$REPO_DIR" "$REPO_DIR/bin/git-config-sync" link

# ── 4. npm security defaults (optional) ────────────────────────────────────
echo ""
read -r -p "Apply npm security defaults (save-exact, ignore-scripts, min-release-age)? (y/N) " sec
if [ "$sec" = "y" ]; then
    bash "$REPO_DIR/scripts/secure-packages.sh"
fi

echo ""
echo "Done. Open a new terminal or run 'source ~/.bashrc' to load the aliases."
echo "Remember to set your git identity:"
echo "    git config --global user.name  \"Your Name\""
echo "    git config --global user.email \"you@example.com\""
