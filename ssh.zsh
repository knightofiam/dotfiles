#!/usr/bin/env zsh
# ssh.zsh — configure SSH authorized_keys
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SSH_DIR="${REPO_ROOT}/ssh"
SSH_KEYS_ORIGINAL="${HOME}/.ssh/authorized_keys"
SSH_KEYS_BACKUP="${HOME}/.ssh.backup/authorized_keys"
SSH_KEYS_REPO="${SSH_DIR}/authorized_keys"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Configuring SSH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Set correct permissions on ssh directory
echo "→ Setting permissions on SSH directory..."
if [[ -d "$SSH_DIR" ]]; then
  chmod 700 "$SSH_DIR"
  echo "✓ Set permissions: 700 on $SSH_DIR"
else
  echo "⚠️  SSH directory not found: $SSH_DIR"
  echo "  Creating it..."
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
  echo "✓ Created: $SSH_DIR"
fi

echo ""

# 2. Copy authorized_keys to repo (for backup/version control)
echo "→ Backing up authorized_keys to repository..."

if [[ -f "$SSH_KEYS_ORIGINAL" ]]; then
  if [[ ! -f "$SSH_KEYS_REPO" ]]; then
    cp "$SSH_KEYS_ORIGINAL" "$SSH_KEYS_REPO"
    echo "✓ Copied from: $SSH_KEYS_ORIGINAL"
    echo "  To: $SSH_KEYS_REPO"
  else
    echo "✓ Already exists in repo: $SSH_KEYS_REPO"
  fi

elif [[ -f "$SSH_KEYS_BACKUP" ]]; then
  if [[ ! -f "$SSH_KEYS_REPO" ]]; then
    cp "$SSH_KEYS_BACKUP" "$SSH_KEYS_REPO"
    echo "✓ Copied from backup: $SSH_KEYS_BACKUP"
    echo "  To: $SSH_KEYS_REPO"
  else
    echo "✓ Already exists in repo: $SSH_KEYS_REPO"
  fi

else
  echo "ℹ️  No authorized_keys found to backup"
  echo "  Checked:"
  echo "    - $SSH_KEYS_ORIGINAL"
  echo "    - $SSH_KEYS_BACKUP"
  echo ""
  echo "  If you need SSH keys, you can:"
  echo "    1. Generate new keys: ssh-keygen -t ed25519"
  echo "    2. Copy $SSH_KEYS_REPO to ~/.ssh/authorized_keys"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SSH configuration complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
