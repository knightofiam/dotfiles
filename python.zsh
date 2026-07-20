#!/usr/bin/env zsh
# python.zsh — configure Python environment
set -euo pipefail

# Detect Homebrew prefix
BREW_PREFIX="${BREW_PREFIX:-/opt/homebrew}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Configuring Python"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Create 'python' symlink to 'python3'
echo "→ Creating 'python' symlink to 'python3'..."
echo "  (Python 2 no longer exists by default, this fixes compatibility)"
echo ""

PYTHON3_PATH="${BREW_PREFIX}/bin/python3"
PYTHON_LINK="${BREW_PREFIX}/bin/python"

if command -v python3 &>/dev/null; then
  PYTHON3_PATH="$(command -v python3)"
fi

if [[ -f "$PYTHON3_PATH" ]]; then
  echo "  From: $PYTHON3_PATH"
  echo "  To:   $PYTHON_LINK"

  if sudo ln -sf "$PYTHON3_PATH" "$PYTHON_LINK"; then
    echo "✓ Symlink created"
  else
    echo "⚠️  Failed to create symlink (may need sudo)"
  fi
else
  echo "⚠️  python3 not found at: $PYTHON3_PATH"
  echo "  Install Python 3 first: brew install python"
fi

echo ""

# 2. Install required Python packages
echo "→ Installing Python packages..."

typeset -a PACKAGES
PACKAGES=(
  "cryptography"
)

for package in "${PACKAGES[@]}"; do
  echo "  Installing: $package"
  if pip3 install "$package"; then
    echo "✓ Installed: $package"
  else
    echo "⚠️  Failed to install: $package"
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Python configuration complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
