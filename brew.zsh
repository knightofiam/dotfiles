#!/usr/bin/env bash
set -euo pipefail

# Detect Homebrew prefix
BREW_PREFIX="/opt/homebrew"
if [[ -x /usr/local/bin/brew && ! -x ${BREW_PREFIX}/bin/brew ]]; then
  BREW_PREFIX="/usr/local"
fi

echo "Checking for Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "Homebrew installed."
fi

# Ensure brew is in this shell and future logins
eval "$(${BREW_PREFIX}/bin/brew shellenv)"
if ! grep -Fq 'brew shellenv' "${HOME}/.zprofile" 2>/dev/null; then
  {
    echo ""
    echo '# Initialize Homebrew (added by brew.sh)'
    echo "eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\""
  } >> "${HOME}/.zprofile"
fi

# Optional: ensure CLT tools are available (harmless if Xcode is set)
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install || true
fi

# Run bundle from this script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "Updating Homebrew..."
brew update

echo "Installing from Brewfile..."
# --no-lock: avoids creating/updating Brewfile.lock.json
brew bundle --file="${SCRIPT_DIR}/Brewfile" --no-lock

echo "Cleaning up..."
brew cleanup -s

echo "✅ Finished Homebrew setup."
