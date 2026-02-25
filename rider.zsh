#!/usr/bin/env zsh
# rider.zsh — configure JetBrains Rider settings
set -euo pipefail

# Platform detection
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "⚠️  This script is macOS-only (Rider configuration)"
  echo "   Skipping on $(uname -s)"
  exit 0
fi

PROPERTIES_FILE="/Applications/Rider.app/Contents/bin/idea.properties"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Configuring JetBrains Rider"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Rider is installed
if [[ ! -f "$PROPERTIES_FILE" ]]; then
  echo "⚠️  Rider not found at: /Applications/Rider.app"
  echo "   Install Rider first, then re-run this script"
  exit 0
fi

echo "→ Enabling unlimited console scrollback depth..."
echo "  File: $PROPERTIES_FILE"
echo ""

# Use sed to replace or add the setting
if grep -xq "^idea.cycle.buffer.size=.*$" "$PROPERTIES_FILE"; then
  # Setting exists, replace it
  echo "  Setting found, updating..."
  if sed -i.bak "s@^idea.cycle.buffer.size=.*@idea.cycle.buffer.size=disabled@g" "$PROPERTIES_FILE"; then
    echo "✓ Setting updated"
  else
    echo "⚠️  Failed to update setting"
  fi
else
  # Setting doesn't exist, add it
  echo "  Setting not found, adding..."
  echo "idea.cycle.buffer.size=disabled" >> "$PROPERTIES_FILE"
  echo "✓ Setting added"
fi

# Verify the change
if grep -xq "^idea.cycle.buffer.size=disabled$" "$PROPERTIES_FILE"; then
  echo "✓ Successfully enabled unlimited console scrollback"
else
  echo "✗ ERROR: Failed to enable unlimited console scrollback"
  exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Rider configuration complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
