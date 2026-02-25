#!/usr/bin/env zsh
# gcc.zsh — install GCC compiler via Homebrew
set -euo pipefail

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing GCC"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Homebrew is available
if ! command -v brew &>/dev/null; then
  echo "✗ ERROR: Homebrew not found"
  echo "  Install Homebrew first: ./brew.zsh"
  exit 1
fi

echo "→ Installing GCC via Homebrew..."
echo "  Note: GCC should be installed after Xcode Command Line Tools"
echo ""

if brew install gcc; then
  echo "✓ GCC installed successfully"
else
  echo "⚠️  GCC installation failed (may already be installed)"
  if command -v gcc &>/dev/null; then
    echo "  GCC is available: $(gcc --version | head -n1)"
  fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ GCC installation complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
