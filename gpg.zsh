#!/usr/bin/env zsh
# gpg.zsh — import a NEW private key from 1Password and set up GPG/pinentry for Git commit signing.

set -euo pipefail

# ----------------- Config (override via env) -----------------
: ${DOC_TITLE:="GPG Private Key (aaron@forerunnergames.com) 2025-10-22.asc"}
: ${VAULT:="Employee"}
: ${GIT_USER_EMAIL:="aaron@forerunnergames.com"}
: ${GIT_SIGNING_KEY:=""}        # if empty, auto-detect from imported key or email
: ${CONFIGURE_GIT:="true"}
: ${CACHE_TTL:="7200"}
: ${CACHE_TTL_MAX:="86400"}

# ----------------- Helpers -----------------
die()  { print -ru2 -- "✗ $*"; exit 1; }
info() { print -- "➜ $*"; }
have() { command -v "$1" >/dev/null 2>&1; }
brew_prefix_or() { if have brew; then brew --prefix; else print -r -- "/opt/homebrew"; fi }

# ----------------- Pre-flight -----------------
have gpg || die "gpg not found. Install with: brew install gnupg"
have op  || die "'op' CLI not found. Install & sign in (op account list; op account use)."

if ! op account get >/dev/null 2>&1; then
  die "Not signed in to 1Password CLI. Run 'op account add' or enable desktop integration."
fi

if [[ -z "$DOC_TITLE" ]]; then
  vared -p "Enter 1Password Document title (e.g. 'My Private Key (YYYY-MM-DD).asc'): " -c DOC_TITLE
  [[ -n "$DOC_TITLE" ]] || die "No document title provided."
fi

# ----------------- pinentry & GnuPG config -----------------
PINENTRY="$(brew_prefix_or)/bin/pinentry-mac"
if [[ ! -x "$PINENTRY" ]]; then
  if have brew; then
    info "Installing pinentry-mac via Homebrew…"
    brew install pinentry-mac
  fi
fi
[[ -x "$PINENTRY" ]] || die "pinentry-mac not found at $PINENTRY"

GNUPG_DIR="$HOME/.gnupg"
mkdir -p "$GNUPG_DIR"; chmod 700 "$GNUPG_DIR"

cat >"$GNUPG_DIR/gpg-agent.conf" <<EOF
pinentry-program $PINENTRY
enable-ssh-support
default-cache-ttl $CACHE_TTL
max-cache-ttl $CACHE_TTL_MAX
EOF
chmod 600 "$GNUPG_DIR/gpg-agent.conf"

cat >"$GNUPG_DIR/gpg.conf" <<'EOF'
use-agent
personal-digest-preferences SHA512 SHA384 SHA256
cert-digest-algo SHA512
no-emit-version
no-comments
EOF
chmod 600 "$GNUPG_DIR/gpg.conf"

info "Reloading gpg-agent…"
gpgconf --kill gpg-agent || true
gpgconf --launch gpg-agent || true

# ----------------- Import from 1Password -----------------
TMPDIR="$(mktemp -d -t gpgkey)"
trap 'rm -rf "$TMPDIR"' EXIT
ASC="$TMPDIR/key.asc"

info "Downloading '$DOC_TITLE' from 1Password vault '$VAULT'…"
op document get "$DOC_TITLE" --vault "$VAULT" --output "$ASC"

info "Importing key into GnuPG…"
gpg --import "$ASC"

# ----------------- Determine the ONE correct fingerprint -----------------
# Preferred path: pick the primary secret key (sec) for the configured email
FPR=""
if [[ -n "${GIT_USER_EMAIL:-}" ]]; then
  FPR="$(gpg --with-colons --list-secret-keys "$GIT_USER_EMAIL" \
    | awk -F: '$1=="sec"{sec=1;next} sec&&$1=="fpr"{print $10; exit}')"
fi

# Fallback: derive the primary fingerprint from the imported file content (the first fpr after 'sec')
if [[ -z "$FPR" ]]; then
  FPR="$(gpg --with-colons --import-options show-only --import "$ASC" 2>/dev/null \
    | awk -F: '$1=="sec"{sec=1;next} sec&&$1=="fpr"{print $10; exit}')"
fi

[[ -n "$FPR" ]] || die "Could not determine a primary fingerprint for the imported key."
info "Primary fingerprint: $FPR"

# ----------------- Configure Git (optional) -----------------
if [[ "$CONFIGURE_GIT" == "true" ]]; then
  # Allow explicit override
  if [[ -n "$GIT_SIGNING_KEY" ]]; then
    FPR="$GIT_SIGNING_KEY"
  fi

  info "Configuring Git to sign with: $FPR"
  git config --global user.signingkey "$FPR"
  git config --global commit.gpgsign true
  git config --global gpg.program gpg

  if [[ -n "${GIT_USER_EMAIL:-}" ]]; then
    git config --global user.email "$GIT_USER_EMAIL"
  fi
fi

info "All set. Next signed commit will prompt once via pinentry, then cache (${CACHE_TTL}s)."
