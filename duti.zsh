#!/usr/bin/env zsh
# duti.zsh — apply Launch Services defaults via duti (uses ./duti2 by default)

set -euo pipefail

# Path to your duti config (default: a file named "duti2" next to this script)
: "${DUTI_FILE:="${0:A:h}/duti2"}"

# Ensure duti is available
if ! command -v duti >/dev/null 2>&1; then
  echo "duti not found. Install it first: brew install duti" >&2
  exit 1
fi

# Ensure config exists
if [[ ! -f "$DUTI_FILE" ]]; then
  echo "Config not found: $DUTI_FILE" >&2
  exit 1
fi

echo "Applying file associations from: $DUTI_FILE"
duti "$DUTI_FILE"

# Optional quick sanity checks (comment out if you want it totally silent)
echo "Done. Examples:"
echo "  duti -x log"
echo "  duti -x mp3"
echo "  duti -d public.yaml"
