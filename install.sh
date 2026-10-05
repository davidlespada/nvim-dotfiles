#!/usr/bin/env bash
set -euo pipefail

# CachyOS / Arch bootstrap for this nvim config.
# Usage:
#   ./install.sh                 # install deps (run from repo root or ~/.config/nvim)
#   curl -sL <raw install.sh> | bash  # future: pipe mode

PACKAGES=(neovim git ripgrep gcc tree-sitter-cli)

if command -v pacman >/dev/null 2>&1; then
  echo "==> Installing system deps via pacman: ${PACKAGES[*]}"
  sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
else
  echo "WARN: pacman not found, install manually: ${PACKAGES[*]}"
fi

# If run outside ~/.config/nvim, offer to install the config there.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.config/nvim"

if [ "$REPO_DIR" != "$TARGET" ]; then
  if [ -d "$TARGET" ] && [ -n "$(ls -A "$TARGET" 2>/dev/null)" ]; then
    BACKUP="$HOME/nvim-backup-$(date +%Y%m%d-%H%M%S)"
    echo "==> Backing up existing $TARGET -> $BACKUP"
    mv "$TARGET" "$BACKUP"
  fi
  echo "==> Copying $REPO_DIR -> $TARGET"
  mkdir -p "$(dirname "$TARGET")"
  cp -a "$REPO_DIR" "$TARGET"
fi

echo "==> Done. Run: nvim  (then :Lazy sync, :checkhealth)"
