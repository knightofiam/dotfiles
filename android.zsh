#!/usr/bin/env zsh

# Android SDK setup
# Configures Android SDK, installs packages, and sets up debug keystore

set -euo pipefail

echo "Setting up Android SDK..."

# Create repositories configuration file to avoid warnings when running,
# e.g., sdkmanager --update.
mkdir -p ~/.android && touch ~/.android/repositories.cfg

# Install packages
if command -v sdkmanager &>/dev/null; then
  sdkmanager "platform-tools" "build-tools;33.0.0" "platforms;android-32" "cmdline-tools;latest"
else
  echo "Warning: sdkmanager not found. Install Android SDK first."
  echo "  brew install --cask android-commandlinetools"
fi

# Create local copy of debug keystore for Godot Android debug exports
if [[ -f ~/Sync/dev/android/debug.keystore ]]; then
  cp ~/Sync/dev/android/debug.keystore ~/.android/
  echo "Copied debug keystore."
else
  echo "Warning: debug.keystore not found at ~/Sync/dev/android/debug.keystore"
fi

echo "Android SDK setup complete."
