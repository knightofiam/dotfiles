#!/usr/bin/env zsh
# mvim.zsh — configure MacVim to open files in tabs instead of windows
set -euo pipefail

# Platform detection
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "⚠️  This script is macOS-only (MacVim configuration)"
  echo "   Skipping on $(uname -s)"
  exit 0
fi

# Detect Homebrew prefix
BREW_PREFIX="${BREW_PREFIX:-/opt/homebrew}"

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
MVIM_SRC="${REPO_ROOT}/vim/mvim"
MVIM_DST="${BREW_PREFIX}/bin/mvim"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Configuring MacVim"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if source file exists
if [[ ! -f "$MVIM_SRC" ]]; then
  echo "✗ ERROR: MacVim wrapper not found: $MVIM_SRC"
  exit 1
fi

# Install modified mvim wrapper
echo "→ Installing modified mvim wrapper..."
echo "  This makes MacVim open files in tabs instead of windows"
echo ""
echo "  From: $MVIM_SRC"
echo "  To:   $MVIM_DST"
echo ""

if cp "$MVIM_SRC" "$MVIM_DST"; then
  chmod +x "$MVIM_DST"
  echo "✓ MacVim wrapper installed"
else
  echo "✗ ERROR: Failed to copy MacVim wrapper"
  echo "  You may need to run with sudo or check permissions"
  exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ MacVim configuration complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "ℹ️  Reference: https://stackoverflow.com/a/9100989/14410393"
