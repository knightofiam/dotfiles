#!/usr/bin/env zsh
# macos.zsh — opinionated but minimal macOS customization (Sequoia / Tahoe)

set -euo pipefail
echo "==> macOS tweaks (Sequoia/Tahoe-safe)"

# Helper for PlistBuddy
PB="/usr/libexec/PlistBuddy"
FINDER_PLIST="$HOME/Library/Preferences/com.apple.finder.plist"

###############################################################################
# Keyboard / Input
###############################################################################

# F1–F12 act as standard function keys (use Fn for media)
defaults write -g com.apple.keyboard.fnState -bool true

# Fastest key repeat allowed by UI
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

# Disable press-and-hold accent popup (use repeats)
defaults write -g ApplePressAndHoldEnabled -bool false

# Full keyboard access: Tab moves focus to all controls (0..3; 3 = all)
# You asked what this is — this enables tabbing to buttons, popups, etc.
defaults write -g AppleKeyboardUIMode -int 3

# Disable “natural” scroll direction
defaults write -g com.apple.swipescrolldirection -bool false

# Disable Force Click (best-effort across domains)
defaults write -g com.apple.trackpad.forceClick -bool false
defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad ForceSuppressed -bool true

# Optional: map Caps Lock to Escape (device-agnostic via hidutil)
# (Takes effect for the current boot; re-run on login if desired.)
/usr/bin/hidutil property --set '{
  "UserKeyMapping": [
    {"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}
  ]
}' >/dev/null

###############################################################################
# Power / Sleep
###############################################################################

# Display sleep: battery 10 min, charger 60 min
sudo pmset -b displaysleep 10
sudo pmset -c displaysleep 60

# Require password immediately after screen off/screensaver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Start screensaver after 5 minutes
defaults -currentHost write com.apple.screensaver idleTime -int 300

###############################################################################
# Control Center / Menu Bar
###############################################################################

# Always show Battery percentage text
defaults write com.apple.controlcenter BatteryShowPercentage -bool true

# Best-effort to show Bluetooth/Wi-Fi/Sound in menu bar (Control Center model)
defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true || true
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi"      -bool true || true
defaults write com.apple.controlcenter "NSStatusItem Visible Sound"     -bool true || true

# Turn off Bluetooth at boot (classic knob; modern macOS may override)
# Tip: brew install blueutil; then: blueutil --power 0   (manual/optional)
# sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0 || true
# sudo killall -HUP blued || true

###############################################################################
# Dock / Mission Control
###############################################################################

# Auto-hide Dock, nearly instant
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0.0
defaults write com.apple.dock autohide-time-modifier -float 0.15

# Don’t rearrange Spaces
defaults write com.apple.dock mru-spaces -bool false

# Hide recent apps in Dock
defaults write com.apple.dock show-recents -bool false

# Disable edge gestures that trigger snapping / tiling
defaults write com.apple.dock showMissionControlGestureEnabled -bool false
defaults write com.apple.dock showAppExposeGestureEnabled -bool false

# Disable “More Gestures” (best-effort; Apple moves these around)
for d in com.apple.AppleMultitouchTrackpad com.apple.driver.AppleBluetoothMultitouch.trackpad; do
  defaults write "$d" TrackpadThreeFingerHorizSwipeGesture -int 0   # swipe pages
  defaults write "$d" TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0  # Notification Center
  defaults write "$d" TrackpadFourFingerVertSwipeGesture -int 0     # Mission Control
  defaults write "$d" TrackpadThreeFingerVertSwipeGesture -int 0    # App Exposé
  defaults write "$d" TrackpadFiveFingerPinchGesture -int 0         # Show Desktop (varies by OS)
done

###############################################################################
# Finder
###############################################################################

# Show path bar & status bar
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Prefer list view in new Finder windows (global default)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Reset per-folder saved views so the global default takes effect everywhere
# (delete .DS_Store under your Home; uncomment the second line for system-wide)
find "$HOME" -name ".DS_Store" -delete 2>/dev/null
# sudo find / -name ".DS_Store" -delete 2>/dev/null   # optional, broader reset

# Prevent writing new .DS_Store files (network + local) to keep folders consistent
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteLocalDesktopStores -bool true

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Filename extensions: you asked to keep “Show all extensions” OFF
defaults write NSGlobalDomain AppleShowAllExtensions -bool false

# “Show warning” prompts ON
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool true
defaults write com.apple.finder WarnOnEmptyTrash -bool true

# Keep folders on top on Desktop, but NOT in Finder windows
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool false

# New Finder windows show your home folder
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"

# Make ~/Library visible
chflags nohidden ~/Library || true

# Desktop icon layout (Kind sort, 32px, specific grid + text size)
# Note: Finder rewrites these; this applies the starting template.
mkdir -p "$(dirname "$FINDER_PLIST")"
$PB -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy kind"        "$FINDER_PLIST" 2>/dev/null || \
$PB -c "Add :DesktopViewSettings:IconViewSettings:arrangeBy string kind" "$FINDER_PLIST" 2>/dev/null || true
$PB -c "Set :DesktopViewSettings:IconViewSettings:iconSize 32"           "$FINDER_PLIST" 2>/dev/null || \
$PB -c "Add :DesktopViewSettings:IconViewSettings:iconSize integer 32"   "$FINDER_PLIST" 2>/dev/null || true
# Grid spacing “4th tick from left” is subjective; pick a stable middle (90)
$PB -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 90"        "$FINDER_PLIST" 2>/dev/null || \
$PB -c "Add :DesktopViewSettings:IconViewSettings:gridSpacing integer 90" "$FINDER_PLIST" 2>/dev/null || true
$PB -c "Set :DesktopViewSettings:IconViewSettings:textSize 14"           "$FINDER_PLIST" 2>/dev/null || \
$PB -c "Add :DesktopViewSettings:IconViewSettings:textSize integer 14"   "$FINDER_PLIST" 2>/dev/null || true

# Open/Save panels expanded by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write -g NSNavPanelExpandedStateForOpenMode -bool true
defaults write -g NSNavPanelExpandedStateForOpenMode2 -bool true

# Screenshots: to Desktop, PNG, no shadow
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# Don't prompt when emptying trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false && killall Finder

###############################################################################
# Apply
###############################################################################
echo "==> Restarting affected services…"
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "✅ Done. Note: some trackpad/gesture and keyboard changes may need a logout/login."
