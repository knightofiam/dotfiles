#!/usr/bin/env zsh
# repos.zsh — configure dotfiles git repository and clone development projects
set -euo pipefail

# Detect Homebrew prefix
BREW_PREFIX="${BREW_PREFIX:-/opt/homebrew}"

# Ensure Homebrew is in PATH
if [[ -x "${BREW_PREFIX}/bin/brew" ]]; then
  eval "$(${BREW_PREFIX}/bin/brew shellenv)"
fi

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Configuring Git Repositories"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Configure dotfiles git repository (if not already initialized)
echo "→ Checking dotfiles git configuration..."

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "  Initializing git repository..."
  git init

  if ! git config remote.origin.url &>/dev/null; then
    echo "  Adding remote origin..."
    git remote add origin https://github.com/knightofiam/dotfiles.git
  fi

  echo "  Fetching from origin..."
  git fetch

  echo "  Setting up branch tracking..."
  git reset origin/master
  git branch --set-upstream-to=origin/master master 2>/dev/null || \
    git branch --set-upstream-to=origin/master

  echo "  Restoring deleted files..."
  git ls-files -z --deleted | xargs -0 git checkout -- 2>/dev/null || true

  echo "  Updating submodules..."
  git submodule update --init --recursive

  echo "✓ Dotfiles git repository configured"
else
  echo "✓ Dotfiles git repository already configured"
fi

echo ""

# 2. Configure GitHub development projects directory structure
echo "→ Setting up development projects directory..."

PROJECTS_BASE="${HOME}/Sync/dev/projects"
GODOT_DIR="${PROJECTS_BASE}/godot"

# Create projects directory structure
mkdir -p "$GODOT_DIR"
echo "✓ Created: $PROJECTS_BASE"
echo "✓ Created: $GODOT_DIR"

echo ""

# 3. Move dotfiles to projects directory (if needed)
echo "→ Checking dotfiles location..."

DOTFILES_OLD="${HOME}/dotfiles"
DOTFILES_NEW="${PROJECTS_BASE}/dotfiles"

if [[ -d "$DOTFILES_OLD" && "$DOTFILES_OLD" != "$REPO_ROOT" ]]; then
  echo "  Moving dotfiles from $DOTFILES_OLD to $DOTFILES_NEW..."
  if [[ ! -d "$DOTFILES_NEW" ]]; then
    mv "$DOTFILES_OLD" "$DOTFILES_NEW"
    echo "✓ Moved dotfiles to: $DOTFILES_NEW"
    echo ""
    echo "⚠️  NOTE: Dotfiles have been moved."
    echo "   You may need to re-run the installation from the new location:"
    echo "   cd $DOTFILES_NEW && ./install-macos.zsh"
  else
    echo "⚠️  WARNING: Both $DOTFILES_OLD and $DOTFILES_NEW exist"
    echo "   Please manually resolve this conflict."
  fi
else
  echo "✓ Dotfiles already in correct location"
fi

echo ""

# 4. Clone development repositories
echo "→ Cloning development repositories..."

typeset -A REPOS
REPOS=(
  "${GODOT_DIR}/coa" "https://github.com/forerunnergames/coa.git"
)

for repo_path repo_url in ${(kv)REPOS}; do
  if [[ -d "$repo_path" ]]; then
    echo "✓ Already exists: $repo_path"
  else
    echo "  Cloning: $repo_url"
    echo "  Into: $repo_path"
    if git clone "$repo_url" "$repo_path"; then
      echo "✓ Cloned successfully"
    else
      echo "✗ Failed to clone $repo_url"
    fi
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Repository configuration complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
