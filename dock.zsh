#!/usr/bin/env zsh
# dock.zsh — configure macOS Dock applications and files
set -euo pipefail

# Platform detection
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "⚠️  This script is macOS-only (Dock configuration)"
  echo "   Skipping on $(uname -s)"
  exit 0
fi

# Check if dockutil is installed
if ! command -v dockutil &>/dev/null; then
  echo "✗ ERROR: dockutil not installed"
  echo "  Install with: brew install dockutil"
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Configuring macOS Dock"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Clear existing Dock
echo "→ Clearing existing Dock items..."
dockutil --remove all --no-restart
echo "✓ Dock cleared"
echo ""

# Helper function to add items with error handling
add_dock_item() {
  local path="$1"
  local extra_args="${2:-}"

  # Expand ~ to home directory
  path="${path/#\~/$HOME}"

  if [[ -e "$path" || "$path" =~ ^https?:// ]]; then
    if eval "dockutil --add \"$path\" $extra_args --no-restart"; then
      echo "✓ Added: $path"
    else
      echo "⚠️  Failed to add: $path"
    fi
  else
    echo "⚠️  Not found (skipping): $path"
  fi
}

# Applications
echo "→ Adding applications..."
add_dock_item "/System/Applications/Launchpad.app"
add_dock_item "/Applications/Firefox.app"
add_dock_item "/Applications/iTerm.app"
add_dock_item "/Applications/MacVim.app"
add_dock_item "/Applications/Rider.app"
add_dock_item "/Applications/Godot_4_3_stable_mono.app"
add_dock_item "/Applications/Unity/Hub/Editor/6000.0.29f1/Unity.app"
add_dock_item "/Applications/Unity Hub.app"
add_dock_item "/Applications/Discord.app"
add_dock_item "/Applications/Upwork.app"
add_dock_item "/Applications/Android Studio.app"
add_dock_item "~/Library/Application Support/Steam/steamapps/common/Aseprite/Aseprite.app"
add_dock_item "/Applications/VMware Fusion.app"
add_dock_item "/Applications/zoom.us.app"
add_dock_item "/System/Applications/Messages.app"
add_dock_item "/System/Applications/FaceTime.app"
add_dock_item "/Applications/Signal.app"
add_dock_item "/Applications/GarageBand.app"
add_dock_item "/System/Applications/Notes.app"
add_dock_item "/System/Applications/Calendar.app"
add_dock_item "/Applications/Numbers.app"
add_dock_item "/System/Applications/Calculator.app"
add_dock_item "/System/Applications/Utilities/Digital Color Meter.app"
add_dock_item "/Applications/1Password.app"
add_dock_item "/System/Applications/Utilities/Activity Monitor.app"
add_dock_item "/System/Applications/Preview.app"
add_dock_item "/System/Applications/QuickTime Player.app"
add_dock_item "/System/Applications/System Preferences.app"
add_dock_item "/Applications/Macs Fan Control.app"
echo ""

# Folders
echo "→ Adding folders..."
add_dock_item "~/Downloads" "--view grid --display folder"
echo ""

# Files
echo "→ Adding files..."
add_dock_item "~/Sync/dev/dotfiles/dotfiles-todo.txt"
add_dock_item "~/Sync/dev/coa/notes/coa-todo.txt"
add_dock_item "~/Sync/dev/vim/vim-tips.txt"
add_dock_item "~/Sync/dev/git/git-tips.txt"
add_dock_item "~/Sync/dev/rider/rider-tips.txt"
add_dock_item "~/Sync/dev/iterm/iterm2-tips.txt"
add_dock_item "~/Sync/dev/godot/godot-tips.txt"
add_dock_item "~/Sync/dev/aseprite/aseprite-tips.txt"
add_dock_item "~/Sync/dev/garageband/garageband-tips.txt"
echo ""

# Web links
echo "→ Adding web links..."
add_dock_item "https://claude.ai/" "--label 'Claude.ai'"
add_dock_item "https://chatgpt.com/?model=o1" "--label 'GPT-4'"
add_dock_item "https://github.com/knightofiam" "--label 'GitHub: knightofiam'"
add_dock_item "https://github.com/forerunnergames" "--label 'GitHub: forerunnergames'"
add_dock_item "https://github.com/knightofiam/dotfiles" "--label 'GitHub: dotfiles'"
add_dock_item "https://downloads.tuxfamily.org/godotengine" "--label 'Godot Downloads'"
add_dock_item "https://cs.smu.ca/~porter/csc/ref/ascii.html" "--label 'ASCII Table'"
echo ""

# Restart Dock to apply changes
echo "→ Restarting Dock to apply changes..."
killall Dock
echo "✓ Dock restarted"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Dock configuration complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
