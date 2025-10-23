#!/usr/bin/env zsh
set -euo pipefail

# --- helpers ---------------------------------------------------------------
add_path_line_if_missing() {
  local line='export PATH="$HOME/.dotnet/tools:$PATH"'
  local zrc="${ZDOTDIR:-$HOME}/.zshrc"
  grep -qsF "$line" "$zrc" 2>/dev/null || {
    echo "➕ Adding .NET tools path to $zrc"
    print -r -- "$line" >> "$zrc"
  }
}

# --- checks ----------------------------------------------------------------
if ! command -v dotnet >/dev/null 2>&1; then
  echo "❌ .NET SDK not found."
  echo "   Install with Homebrew:  brew install --cask dotnet-sdk"
  exit 1
fi

# --- install/update NSwag --------------------------------------------------
if dotnet tool list -g | grep -q '^NSwag.ConsoleCore'; then
  echo "⤴️  Updating NSwag..."
  dotnet tool update --global NSwag.ConsoleCore
else
  echo "⬇️  Installing NSwag..."
  dotnet tool install --global NSwag.ConsoleCore
fi

# --- PATH & verification ---------------------------------------------------
add_path_line_if_missing
export PATH="$HOME/.dotnet/tools:$PATH"

echo "✅ Done. NSwag version:"
nswag version || {
  echo "If the command isn’t found in new shells, run: exec zsh"
  exit 1
}
