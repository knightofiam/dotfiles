#!/usr/bin/env zsh

# Automated Dotfiles VM Test
# Clones a fresh macOS VM, installs dotfiles, validates results, cleans up.
#
# Usage:
#   ./quick-test.zsh                    # Test on Sonoma (default)
#   ./quick-test.zsh sequoia            # Test on Sequoia
#   ./quick-test.zsh sonoma --keep-vm   # Keep VM after test for inspection
#   ./quick-test.zsh --full             # Run full install (not just dry-run)
#   ./quick-test.zsh --branch feat/xyz  # Test a specific branch

set -euo pipefail

# ── Config ───────────────────────────────────────────────────────────
MACOS_VERSION="sonoma"
KEEP_VM=false
FULL_INSTALL=false
BRANCH="modernize-dotfiles"
REPO_URL="https://github.com/knightofiam/dotfiles.git"
VM_USER="admin"
VM_PASS="admin"
VM_NAME=""
VM_IP=""

# ── Parse args ───────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    sonoma|sequoia|ventura) MACOS_VERSION="$1" ;;
    --keep-vm)   KEEP_VM=true ;;
    --full)      FULL_INSTALL=true ;;
    --branch)    BRANCH="$2"; shift ;;
    --help|-h)
      sed -n '2,9s/^# //p' "$0"
      exit 0
      ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
  shift
done

VM_NAME="dotfiles-test-${MACOS_VERSION}-$$"

# ── Image registry ───────────────────────────────────────────────────
typeset -A IMAGES=(
  [sonoma]="ghcr.io/cirruslabs/macos-sonoma-base:latest"
  [sequoia]="ghcr.io/cirruslabs/macos-sequoia-base:latest"
  [ventura]="ghcr.io/cirruslabs/macos-ventura-base:latest"
)
IMAGE="${IMAGES[$MACOS_VERSION]}"
BASE_VM="${MACOS_VERSION}-base"

# ── Helpers ──────────────────────────────────────────────────────────
info()    { printf "\033[0;34m[INFO]\033[0m %s\n" "$1"; }
ok()      { printf "\033[0;32m[OK]\033[0m   %s\n" "$1"; }
warn()    { printf "\033[1;33m[WARN]\033[0m %s\n" "$1"; }
fail()    { printf "\033[0;31m[FAIL]\033[0m %s\n" "$1"; }
section() { printf "\n\033[0;34m━━━ %s ━━━\033[0m\n" "$1"; }

SSH_OPTS=(-o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no)

vm_ssh() {
  sshpass -p "$VM_PASS" ssh "${SSH_OPTS[@]}" "${VM_USER}@${VM_IP}" "$@"
}

cleanup() {
  if [[ -n "$VM_NAME" ]]; then
    tart stop "$VM_NAME" 2>/dev/null || true
    if $KEEP_VM; then
      warn "VM kept: $VM_NAME (delete with: tart delete $VM_NAME)"
    else
      tart delete "$VM_NAME" 2>/dev/null || true
      info "VM deleted: $VM_NAME"
    fi
  fi
}
trap cleanup EXIT INT TERM

wait_for_ssh() {
  local attempts=0 max=20
  info "Waiting for VM to boot..."
  sleep 15
  while (( attempts < max )); do
    VM_IP=$(tart ip "$VM_NAME" 2>/dev/null || true)
    if [[ -n "$VM_IP" ]] && vm_ssh "true" 2>/dev/null; then
      ok "VM ready at $VM_IP"
      return 0
    fi
    (( attempts++ )) || true
    sleep 5
  done
  fail "VM did not become reachable after $((max * 5 + 15))s"
  return 1
}

# ── Preflight ────────────────────────────────────────────────────────
section "Preflight"

for cmd in tart sshpass; do
  if ! command -v "$cmd" &>/dev/null; then
    fail "$cmd not installed (brew install ${cmd})"
    exit 1
  fi
done
ok "tart $(tart --version) + sshpass found"

# ── Base image ───────────────────────────────────────────────────────
if ! tart list | grep -q "$BASE_VM"; then
  info "Downloading $IMAGE (~20 GB, one-time)..."
  tart clone "$IMAGE" "$BASE_VM"
  ok "Base image ready"
else
  ok "Base image exists: $BASE_VM"
fi

# ── Create & boot VM ────────────────────────────────────────────────
section "VM Setup"

tart clone "$BASE_VM" "$VM_NAME"
ok "Cloned $BASE_VM -> $VM_NAME"

tart run --no-graphics "$VM_NAME" &
wait_for_ssh

# Passwordless sudo so scripts don't hang
vm_ssh "echo '$VM_PASS' | sudo -S sh -c 'echo \"$VM_USER ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/$VM_USER'" 2>/dev/null
ok "Passwordless sudo configured"

# Pre-set login shell so chsh doesn't prompt for password
vm_ssh "eval \"\$(/opt/homebrew/bin/brew shellenv 2>/dev/null)\"; \
        if command -v brew &>/dev/null; then \
          echo '$VM_PASS' | chsh -s /opt/homebrew/bin/zsh 2>/dev/null || true; \
        fi" 2>/dev/null
ok "Login shell pre-configured"

# ── Clone repo ───────────────────────────────────────────────────────
section "Install"

vm_ssh "git clone -b $BRANCH $REPO_URL ~/dotfiles" 2>&1
ok "Cloned $BRANCH"

# ── Dry run ──────────────────────────────────────────────────────────
info "Running dry-run..."
vm_ssh "cd ~/dotfiles && ./install-macos.zsh --dry-run --skip-private" 2>&1
ok "Dry run passed"

# ── Full install (optional) ──────────────────────────────────────────
if $FULL_INSTALL; then
  info "Running full install (this may take several minutes)..."
  local exit_code=0
  vm_ssh "cd ~/dotfiles && ./install-macos.zsh --skip-private" 2>&1 || exit_code=$?

  if (( exit_code != 0 )); then
    warn "Install exited $exit_code (some scripts may require 1Password or other credentials)"
  fi

  # ── Validate ─────────────────────────────────────────────────────
  section "Validation"

  local failures=0

  # Check symlinks
  info "Checking symlinks..."
  local expected_links=(
    ".zshrc:dotfiles/zsh/zshrc"
    ".vimrc:dotfiles/vim/vimrc"
    ".gitconfig:dotfiles/git/gitconfig"
    ".pandora:dotfiles/pandora"
  )
  for entry in "${expected_links[@]}"; do
    local link="${entry%%:*}"
    local target="${entry#*:}"
    if vm_ssh "readlink ~/$link 2>/dev/null | grep -q '$target'" 2>/dev/null; then
      ok "~/$link -> $target"
    else
      fail "~/$link not linked correctly"
      (( failures++ )) || true
    fi
  done

  # Check brew is functional
  if vm_ssh "eval \"\$(/opt/homebrew/bin/brew shellenv)\"; command -v brew" &>/dev/null; then
    ok "Homebrew functional"
  else
    fail "Homebrew not working"
    (( failures++ )) || true
  fi

  # Check key brew packages
  info "Checking key packages..."
  for pkg in git vim gpg pianobar duti; do
    if vm_ssh "eval \"\$(/opt/homebrew/bin/brew shellenv)\"; command -v $pkg" &>/dev/null; then
      ok "$pkg installed"
    else
      warn "$pkg not found (may need manual install or credentials)"
    fi
  done

  # Check shell
  if vm_ssh "dscl . -read /Users/$VM_USER UserShell 2>/dev/null | grep -q zsh" 2>/dev/null; then
    ok "Login shell is zsh"
  else
    warn "Login shell may not be zsh"
  fi

  # Check zshrc loads
  if vm_ssh "eval \"\$(/opt/homebrew/bin/brew shellenv)\"; zsh -ic 'echo zshrc-ok' 2>/dev/null | grep -q zshrc-ok" 2>/dev/null; then
    ok "zshrc loads without errors"
  else
    warn "zshrc may have load errors"
  fi

  section "Results"
  if (( failures == 0 )); then
    ok "All checks passed on macOS $MACOS_VERSION"
  else
    fail "$failures check(s) failed"
  fi
else
  info "Skipping full install (use --full to run it)"
fi

section "Done"
ok "Test complete for macOS $MACOS_VERSION"
