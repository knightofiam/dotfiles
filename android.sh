#!/usr/bin/env bash

# Create repositories configuration file to avoid warnings when running,
# e.g., sdkmanager --update.
mkdir -p ~/.android && touch ~/.android/repositories.cfg

# Install packages.
sdkmanager "platform-tools" "build-tools;33.0.0" "platforms;android-32" "cmdline-tools;latest"

# Create local copy of debug keystore for Godot Android debug exports.
cp ~/Sync/dev/android/debug.keystore ~/.android/
