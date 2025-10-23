#!/usr/bin/env zsh
set -euo pipefail

# Config file (editable list you maintain)
PLUG_LIST="${PLUG_LIST:-$(git rev-parse --show-toplevel)/vim-plugins.txt}"

# Ensure we run from the repo root
cd -- "$(git rev-parse --show-toplevel 2>/dev/null || { echo "Run inside your dotfiles repo"; exit 1; })"

if [[ ! -f "$PLUG_LIST" ]]; then
  echo "Plugin list not found: $PLUG_LIST"
  exit 1
fi

# Read list into associative maps
typeset -A URL; typeset -A BR
while IFS=$' \t' read -r path url branch || [[ -n "${path:-}" ]]; do
  # Skip comments/blank
  [[ -z "${path:-}" || "${path:-}" == \#* ]] && continue
  [[ -z "${url:-}" ]] && { echo "Invalid line (missing URL): $path"; exit 1; }
  URL[$path]="$url"
  BR[$path]="${branch:-master}"
done < "$PLUG_LIST"

echo "==> Normalizing .gitmodules entries from: $PLUG_LIST"
for path url in ${(kv)URL}; do
  branch="${BR[$path]}"

  # Add submodule if missing
  if ! git config -f .gitmodules --get-regexp "^submodule\\.${path//\//\\/}\\." >/dev/null 2>&1; then
    echo "  • adding $path ($url @ $branch)"
    # Try to add shallow (git submodule add doesn't do depth, so we shallow after)
    git submodule add -b "$branch" "$url" "$path" || true
  fi

  # Ensure correct URL & branch
  git submodule set-url "$path" "$url"
  git submodule set-branch --branch "$branch" "$path"
done

echo "==> Syncing submodule config…"
git submodule sync --recursive

echo "==> Initializing submodules (shallow)…"
git submodule update --init --recursive --depth 1 || true

repair_submodule() {
  local path="$1"
  local url="${URL[$path]}"
  local branch="${BR[$path]}"
  echo "  ⚙  Repairing $path (deinit & clean re-add)…"
  git submodule deinit -f -- "$path" || true
  rm -rf ".git/modules/$path" "$path"
  git submodule add -b "$branch" "$url" "$path"
  # Shallow fetch/checkout
  git -C "$path" fetch --depth=1 origin "$branch"
  git -C "$path" checkout -B "$branch" "origin/$branch"
  git -C "$path" reset --hard "origin/$branch"
}

echo "==> Updating submodules to remote tips (rebase, shallow)…"
# Try fast path
if ! git submodule update --remote --rebase --depth 1; then
  echo "==> Rebase failed for one or more submodules; repairing offenders…"
  for path url in ${(kv)URL}; do
    branch="${BR[$path]}"
    echo "  • Checking $path"
    if ! git -C "$path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      repair_submodule "$path"
      continue
    fi
    git -C "$path" remote set-url origin "$url" || true
    if ! git -C "$path" fetch --depth=1 origin "$branch" >/dev/null 2>&1 \
       || ! git -C "$path" checkout -B "$branch" "origin/$branch" >/dev/null 2>&1 \
       || ! git -C "$path" rebase --rebase-merges "origin/$branch" >/dev/null 2>&1; then
      repair_submodule "$path"
    fi
  done
fi

echo "==> Absorbing gitdirs & final sync…"
git submodule absorbgitdirs || true
git submodule sync --recursive

echo "==> Staging submodule state…"
git add .gitmodules ${(k)URL}

if ! git diff --cached --quiet; then
  git commit -m "vim: update plugin submodules from $PLUG_LIST"
else
  echo "==> No changes to commit."
fi

echo "✅ Done."
