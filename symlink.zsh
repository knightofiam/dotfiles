#!/usr/bin/env zsh
# symlink.zsh — create/update symlinks listed in ./symlinks2
# Format per line: <target-path> <repo-relative-source>
# Example:
#   ~/.zshrc                 zsh/zshrc
#   ~/.vim                   vim
#   ~/.vimrc                 vim/vimrc
#
# Flags:
#   --dry-run   Show what would be done without changing anything
#   --prune     Remove symlinks in $HOME that point into this repo but aren't listed

set -euo pipefail

# -------------------------
# Repo paths & list file
# -------------------------
REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$REPO_ROOT" ]]; then
  echo "Error: run this inside your dotfiles repo (or ensure it's a git repo)." >&2
  exit 1
fi

LIST_FILE="${LIST_FILE:-$REPO_ROOT/symlinks2}"

# -------------------------
# Flags
# -------------------------
DRY_RUN=false
PRUNE=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --prune)   PRUNE=true ;;
    *) echo "Unknown arg: $arg"; echo "Usage: $0 [--dry-run] [--prune]"; exit 1 ;;
  esac
done

# -------------------------
# Helpers
# -------------------------

# Expand ~ safely (don’t eval arbitrary text)
expandpath() {
  local p="$1"
  if [[ "$p" == "~"* ]]; then
    print -r -- "${p/#\~/$HOME}"
  else
    print -r -- "$p"
  fi
}

backup_if_needed() {
  local target="$1"
  local want_link="$2"

  if [[ -e "$target" || -L "$target" ]]; then
    # If it's already the correct symlink, skip backup
    if [[ -L "$target" ]]; then
      local cur
      cur="$(readlink "$target")"
      if [[ "$cur" == "$want_link" ]]; then
        return 0
      fi
    fi
    local ts bk
    ts="$(date +%Y%m%d%H%M%S)"
    bk="${target}.bak.${ts}"
    echo "  - Backing up existing: $target -> $bk"
    $DRY_RUN || mv -f "$target" "$bk"
  fi
}

ensure_parent_dir() {
  local target="$1"
  local dir
  dir="$(dirname "$target")"
  if [[ ! -d "$dir" ]]; then
    echo "  - Creating parent directory: $dir"
    $DRY_RUN || mkdir -p "$dir"
  fi
}

# Create a relative link if possible (falls back to absolute)
relativize_or_abs() {
  local source="$1"
  local target="$2"

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$source" "$target" <<'PY' || true
import os, sys
if len(sys.argv) < 3:
    sys.exit(2)
src, dst = sys.argv[1], sys.argv[2]
try:
    print(os.path.relpath(src, os.path.dirname(dst)))
except Exception:
    print(src)
PY
  else
    # No python3? Use absolute
    printf "%s" "$source"
  fi
}

link_one() {
  local target="$1"
  local source_rel="$2"
  local source="$REPO_ROOT/$source_rel"

  if [[ ! -e "$source" ]]; then
    echo "✗ Missing source in repo: $source_rel" >&2
    return 1
  fi

  ensure_parent_dir "$target"

  local rel_source
  rel_source="$(relativize_or_abs "$source" "$target")"

  # If already linked as desired, skip
  if [[ -L "$target" && "$(readlink "$target")" == "$rel_source" ]]; then
    echo "✓ Already linked: $target -> $rel_source"
    return 0
  fi

  backup_if_needed "$target" "$rel_source"
  echo "→ Linking: $target -> $rel_source"
  $DRY_RUN || ln -sfn "$rel_source" "$target"
}

# -------------------------
# Main
# -------------------------
if [[ ! -f "$LIST_FILE" ]]; then
  echo "Error: symlink list not found: $LIST_FILE" >&2
  exit 1
fi

echo "==> Reading list: $LIST_FILE"
typeset -A listed

# Read line-by-line, allow tabs/spaces, ignore comments and blank lines
while IFS= read -r line || [[ -n "${line:-}" ]]; do
  # Strip comments
  line="${line%%#*}"
  # Trim leading/trailing whitespace
  line="${${line##[[:space:]]}%%[[:space:]]}"

  [[ -z "$line" ]] && continue

  # Split into words (zsh word-splitting on IFS)
  set -A fields -- ${=line}
  if (( ${#fields[@]} < 2 )); then
    echo "Skipping malformed line (need <target> <source>): $line" >&2
    continue
  fi

  local tgt_raw="${fields[1]}"
  local src_rel="${fields[2]}"

  local tgt
  tgt="$(expandpath "$tgt_raw")"

  link_one "$tgt" "$src_rel"
  listed["$tgt"]=1
done < "$LIST_FILE"

if $PRUNE; then
  echo "==> Pruning symlinks that point into repo but are not listed…"
  # Limit the search to common top-level dotfiles + a few paths
  for candidate in ~/.{*,config} ~/.vim ~/.ideavimrc 2>/dev/null; do
    [[ -L "$candidate" ]] || continue
    local dest
    dest="$(readlink "$candidate")"
    # Resolve to absolute for compare
    if [[ "$dest" != /* ]]; then
      dest="$(cd "$(dirname "$candidate")" && realpath "$dest" 2>/dev/null || true)"
    fi
    if [[ -n "$dest" && "$dest" == "$REPO_ROOT"* && -z "${listed[$candidate]-}" ]]; then
      echo "  - Removing unmanaged link: $candidate"
      $DRY_RUN || rm -f "$candidate"
    fi
  done
fi

echo "✅ Done."
