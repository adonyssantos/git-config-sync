#!/usr/bin/env bash
# Hardens npm package installation defaults:
#   save-exact      – pins exact versions (no ^/~ ranges)
#   min-release-age – waits 7 days before allowing a newly published package
#   ignore-scripts  – prevents malicious postinstall scripts from running
#
# These defaults reduce the blast radius of supply-chain attacks. `ignore-scripts`
# in particular can break packages that rely on build steps (e.g. native addons);
# run `npm rebuild` or install those with `--foreground-scripts` when needed.

set -euo pipefail

mkdir -p "$HOME/.config/npm"
cat > "$HOME/.config/npm/.npmrc" << 'EOF'
save-exact = true
min-release-age = 7d
ignore-scripts = true
EOF

ln -sf "$HOME/.config/npm/.npmrc" "$HOME/.npmrc"

echo "npm security defaults written to ~/.config/npm/.npmrc and symlinked to ~/.npmrc"
