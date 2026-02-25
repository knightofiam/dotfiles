#!/usr/bin/env zsh
# private.zsh — configure private settings and run private post-install script
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
POST_INSTALL="${HOME}/Sync/dev/dotfiles/post-install.sh"
EXTRA_TEMPLATE="${REPO_ROOT}/extra"
EXTRA_SRC="${HOME}/Sync/dev/dotfiles/.extra"
EXTRA_DST="${HOME}/.extra"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Configuring Private Settings"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Configure ~/.extra for local/private settings
echo "→ Configuring ${EXTRA_DST} for private settings..."
echo ""

if [[ ! -e "$EXTRA_DST" && -e "$EXTRA_SRC" ]]; then
  echo "  Symlinking existing private config:"
  echo "  From: $EXTRA_SRC"
  echo "  To:   $EXTRA_DST"
  ln -sfh "$EXTRA_SRC" "$EXTRA_DST"
  echo "✓ Symlink created"

elif [[ ! -e "$EXTRA_DST" && ! -e "$EXTRA_SRC" ]]; then
  echo "⚠️  WARNING: Private config not found: $EXTRA_SRC"

  if [[ -f "$EXTRA_TEMPLATE" ]]; then
    echo "  Copying template to: $EXTRA_DST"
    cp "$EXTRA_TEMPLATE" "$EXTRA_DST"
    echo "✓ Template copied"
    echo ""
    echo "  ℹ️  Edit $EXTRA_DST to add your private settings"
  else
    echo "✗ ERROR: Template not found: $EXTRA_TEMPLATE"
    echo "  Cannot create $EXTRA_DST"
  fi

else
  echo "✓ Private config already exists: $EXTRA_DST"
  echo "  (Skipping to avoid overwriting)"
fi

echo ""

# Run private post-install script (if exists)
echo "→ Running private post-install script..."
echo ""

if [[ -f "$POST_INSTALL" ]]; then
  echo "  Executing: $POST_INSTALL"
  echo ""

  if [[ -x "$POST_INSTALL" ]]; then
    if "$POST_INSTALL"; then
      echo ""
      echo "✓ Private post-install completed successfully"
    else
      echo ""
      echo "⚠️  WARNING: Private post-install failed (exit code: $?)"
      echo "  You may need to run it manually:"
      echo "  $POST_INSTALL"
    fi
  else
    echo "✗ ERROR: Post-install script not executable: $POST_INSTALL"
    echo "  Run: chmod +x $POST_INSTALL"
  fi

else
  echo "ℹ️  No private post-install script found: $POST_INSTALL"
  echo "  (This is optional - skipping)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Private settings configuration complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
