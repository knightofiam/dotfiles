#!/usr/bin/env zsh

# Quick Local Testing Script
# Usage: ./quick-test.zsh

set -euo pipefail

echo "🚀 Quick Dotfiles Test"
echo ""

# Config
BASE_VM="sonoma-base"
TEST_VM="dotfiles-test-$$"

# Check if Tart is installed
if ! command -v tart &> /dev/null; then
  echo "❌ Tart not installed"
  echo "   Run: brew install cirruslabs/cli/tart"
  exit 1
fi

# Check if base VM exists
if ! tart list | grep -q "^${BASE_VM}"; then
  echo "❌ Base VM not found: $BASE_VM"
  echo ""
  echo "First-time setup (this takes 10-30 minutes):"
  echo "  tart clone ghcr.io/cirruslabs/macos-sonoma-base:latest sonoma-base"
  echo ""
  read -q "CONFIRM?Run setup now? (y/n) "
  echo ""

  if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "⬇️  Downloading macOS Sonoma base image (~20GB)..."
    tart clone ghcr.io/cirruslabs/macos-sonoma-base:latest sonoma-base
    echo "✅ Base VM ready!"
  else
    exit 1
  fi
fi

# Clean up any existing test VM
if tart list | grep -q "^${TEST_VM}"; then
  echo "🧹 Cleaning up old test VM..."
  tart delete "$TEST_VM"
fi

# Create test VM
echo "📦 Creating test VM from base..."
tart clone "$BASE_VM" "$TEST_VM"

echo ""
echo "✅ Test VM ready: $TEST_VM"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Next steps:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Start the VM:"
echo "   tart run $TEST_VM"
echo ""
echo "2. Inside the VM (Terminal):"
echo "   git clone YOUR_REPO_URL"
echo "   cd dotfiles"
echo "   ./install-macos.zsh"
echo ""
echo "3. When done, quit VM (Cmd+Q)"
echo ""
echo "4. Clean up:"
echo "   tart delete $TEST_VM"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Offer to start VM immediately
echo ""
read -q "START?Start VM now? (y/n) "
echo ""

if [[ "$START" =~ ^[Yy]$ ]]; then
  echo "🚀 Starting VM..."
  echo "   (GUI will open - use it like a regular Mac)"
  tart run "$TEST_VM"

  # After VM closes
  echo ""
  read -q "DELETE?Delete test VM? (y/n) "
  echo ""

  if [[ "$DELETE" =~ ^[Yy]$ ]]; then
    tart delete "$TEST_VM"
    echo "✅ Test VM deleted"
  else
    echo "⚠️  Test VM preserved: $TEST_VM"
    echo "   Delete later with: tart delete $TEST_VM"
  fi
fi
