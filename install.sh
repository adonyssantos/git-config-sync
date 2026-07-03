#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# dotsync — installer
#
# Install just the CLI, straight from the internet:
#
#     curl -fsSL https://raw.githubusercontent.com/adonyssantos/dotsync/main/install.sh | bash
#
# Or run it from a local clone to also set up this repo's own dotfiles:
#
#     git clone https://github.com/adonyssantos/dotsync.git
#     bash dotsync/install.sh
#
# What it does:
#   1. Installs the `dotsync` CLI into ~/.local/bin (cloning the repo to
#      ~/.local/share/dotsync first when run via curl).
#   2. When run interactively from inside a clone, offers to symlink that repo's
#      config into $HOME (backing up existing files) and apply npm defaults.
#
# Re-running is safe.
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

REPO_URL="${DOTSYNC_REPO_URL:-https://github.com/adonyssantos/dotsync.git}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/dotsync"
BIN_DIR="$HOME/.local/bin"

# Interactive only when stdin is a real terminal (never under `curl | bash`).
interactive() { [ -t 0 ]; }

# ── Resolve where the repo (and thus the CLI) lives ──────────────────────────
SELF="${BASH_SOURCE[0]:-}"
if [ -n "$SELF" ] && SELF_DIR="$(cd "$(dirname "$SELF")" 2>/dev/null && pwd)" \
        && [ -f "$SELF_DIR/bin/dotsync" ]; then
    # Running from inside a clone — use it directly.
    REPO_DIR="$SELF_DIR"
    IN_REPO=1
else
    # Piped from curl (or no local copy): clone/update into DATA_DIR.
    IN_REPO=0
    if [ -d "$DATA_DIR/.git" ]; then
        echo "==> Updating existing clone at $DATA_DIR"
        git -C "$DATA_DIR" pull --ff-only
    else
        echo "==> Cloning $REPO_URL into $DATA_DIR"
        mkdir -p "$(dirname "$DATA_DIR")"
        git clone "$REPO_URL" "$DATA_DIR"
    fi
    REPO_DIR="$DATA_DIR"
fi

# ── 1. Install the CLI ───────────────────────────────────────────────────────
chmod +x "$REPO_DIR/bin/dotsync"
mkdir -p "$BIN_DIR"
ln -sf "$REPO_DIR/bin/dotsync" "$BIN_DIR/dotsync"
echo "==> Installed CLI: $BIN_DIR/dotsync -> $REPO_DIR/bin/dotsync"
case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) echo "  ! $BIN_DIR is not on your PATH. Add this to your shell rc:"
       echo "        export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac

# ── 2. Optionally set up THIS repo's dotfiles (interactive, in-repo only) ─────
if [ "$IN_REPO" -eq 1 ] && interactive; then
    echo ""
    read -r -p "Also symlink this repo's config into \$HOME (backs up existing files)? (y/N) " link_choice
    if [ "$link_choice" = "y" ]; then
        DOTSYNC_DIR="$REPO_DIR" "$REPO_DIR/bin/dotsync" link
        echo ""
        read -r -p "Apply npm security defaults (save-exact, ignore-scripts, min-release-age)? (y/N) " sec
        if [ "$sec" = "y" ]; then
            bash "$REPO_DIR/scripts/secure-packages.sh"
        fi
    fi
fi

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "Done. Next steps:"
echo "  1. Make sure ~/.local/bin is on your PATH (see above if warned)."
echo "  2. Point dotsync at your dotfiles repo:"
echo "        dotsync init https://github.com/<you>/<your-dotfiles>.git"
echo "        dotsync link"
echo "  3. Check everything is wired up:"
echo "        dotsync doctor"
