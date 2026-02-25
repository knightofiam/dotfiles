#!/usr/bin/env zsh
# install-macos.zsh — orchestrates dotfiles installation on macOS
# Runs individual setup scripts in dependency order

set -euo pipefail

# =====================================================================
# Configuration
# =====================================================================

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =====================================================================
# Flags
# =====================================================================

DRY_RUN=false
SKIP_PRIVATE=false

print_usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Install and configure dotfiles on macOS.

OPTIONS:
  --dry-run        Show what would be done without making changes
  --skip-private   Skip private repository setup
  --help           Show this help message

EXAMPLES:
  $0                    # Full installation
  $0 --dry-run          # Preview changes
  $0 --skip-private     # Skip private repos setup

EOF
}

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      echo "${BLUE}[DRY RUN MODE]${NC} No changes will be made."
      ;;
    --skip-private)
      SKIP_PRIVATE=true
      ;;
    --help|-h)
      print_usage
      exit 0
      ;;
    *)
      echo "${RED}Error: Unknown argument '$arg'${NC}" >&2
      print_usage
      exit 1
      ;;
  esac
done

# =====================================================================
# Platform Detection
# =====================================================================

detect_platform() {
  case "$(uname -s)" in
    Darwin)
      echo "macos"
      ;;
    Linux)
      echo "linux"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

PLATFORM="$(detect_platform)"

if [[ "$PLATFORM" != "macos" ]]; then
  echo "${RED}Error: This script is for macOS only.${NC}" >&2
  echo "For Linux, use: ./install-linux.zsh" >&2
  exit 1
fi

# =====================================================================
# Helper Functions
# =====================================================================

log_section() {
  echo ""
  echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo "${BLUE}$1${NC}"
  echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

log_info() {
  echo "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo "${GREEN}[✓]${NC} $1"
}

log_warning() {
  echo "${YELLOW}[!]${NC} $1"
}

log_error() {
  echo "${RED}[✗]${NC} $1" >&2
}

log_skip() {
  echo "${YELLOW}[SKIP]${NC} $1"
}

# Run a script if it exists
run_script() {
  local script_name="$1"
  local description="${2:-$script_name}"

  # Prefer .zsh version, fallback to .sh
  local script_path=""
  if [[ -f "${REPO_ROOT}/${script_name}.zsh" ]]; then
    script_path="${REPO_ROOT}/${script_name}.zsh"
  elif [[ -f "${REPO_ROOT}/${script_name}.sh" ]]; then
    script_path="${REPO_ROOT}/${script_name}.sh"
  else
    log_warning "Script not found: ${script_name} (skipping)"
    return 0
  fi

  log_info "Running: $description"

  if $DRY_RUN; then
    log_info "[DRY RUN] Would execute: $script_path"
    return 0
  fi

  if [[ -x "$script_path" ]]; then
    if "$script_path"; then
      log_success "$description completed"
    else
      log_error "$description failed (exit code: $?)"
      return 1
    fi
  else
    log_error "Script not executable: $script_path"
    return 1
  fi
}

# =====================================================================
# Pre-Installation Checks
# =====================================================================

log_section "Pre-Installation Checks"

log_info "Platform: macOS"
log_info "macOS Version: $(sw_vers -productVersion)"
log_info "Architecture: $(uname -m)"
log_info "Repository: $REPO_ROOT"

# Check if Xcode Command Line Tools are installed
if ! xcode-select -p >/dev/null 2>&1; then
  log_warning "Xcode Command Line Tools not installed"
  log_info "Will be installed by brew.zsh"
fi

# =====================================================================
# Installation Sequence
# =====================================================================

log_section "Starting Installation"

# Track failures
typeset -a FAILED_SCRIPTS

# 1. Homebrew (required for everything else)
run_script "brew" "Homebrew installation & package management" || FAILED_SCRIPTS+=("brew")

# Ensure brew is in PATH for subsequent scripts (brew.zsh runs as a subprocess)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 2. Shell setup (zsh, Touch ID for sudo)
run_script "shell" "Shell configuration (zsh, Touch ID)" || FAILED_SCRIPTS+=("shell")

# 3. macOS system preferences
run_script "macos" "macOS system preferences & tweaks" || FAILED_SCRIPTS+=("macos")

# 4. Development tools & SDKs
run_script "gcc" "GCC compiler setup" || FAILED_SCRIPTS+=("gcc")
run_script "python" "Python environment setup" || FAILED_SCRIPTS+=("python")
run_script "android" "Android SDK setup" || FAILED_SCRIPTS+=("android")

# 5. GPG & signing
run_script "gpg" "GPG configuration (1Password integration)" || FAILED_SCRIPTS+=("gpg")

# 6. SSH configuration
run_script "ssh" "SSH keys & configuration" || FAILED_SCRIPTS+=("ssh")

# 7. Editor & IDE setup
run_script "mvim" "MacVim installation & configuration" || FAILED_SCRIPTS+=("mvim")
run_script "rider" "JetBrains Rider configuration" || FAILED_SCRIPTS+=("rider")

# 8. File associations
run_script "duti" "File type associations (duti)" || FAILED_SCRIPTS+=("duti")

# 9. Dock configuration
run_script "dock" "macOS Dock configuration" || FAILED_SCRIPTS+=("dock")

# 10. Git repositories
run_script "repos" "Clone development repositories" || FAILED_SCRIPTS+=("repos")

# 11. Private repositories (optional)
if $SKIP_PRIVATE; then
  log_skip "Private repository setup (--skip-private flag used)"
else
  run_script "private" "Private repository & secrets setup" || FAILED_SCRIPTS+=("private")
fi

# 12. Symlink dotfiles (last, so configs are ready)
run_script "symlink" "Create dotfile symlinks" || FAILED_SCRIPTS+=("symlink")

# 13. Tart guest agent (only inside Apple VMs)
if system_profiler SPHardwareDataType 2>/dev/null | grep -q 'VirtualMac'; then
  log_info "Apple VM detected — installing Tart guest agent for clipboard sharing..."
  if $DRY_RUN; then
    log_info "[DRY RUN] Would install tart-guest-agent"
  elif launchctl list 2>/dev/null | grep -q 'tart-guest-agent'; then
    log_success "Tart guest agent already running"
  else
    local tga_url="https://github.com/cirruslabs/tart-guest-agent/releases/latest/download/tart-guest-agent-darwin-all.tar.gz"
    local tga_tmp="/tmp/tart-guest-agent-install"
    local tga_plist="/Library/LaunchAgents/org.cirruslabs.tart-guest-agent.plist"
    mkdir -p "$tga_tmp"
    if curl -sL "$tga_url" | tar xz -C "$tga_tmp"; then
      sudo cp "$tga_tmp/tart-guest-agent" /usr/local/bin/
      sudo tee "$tga_plist" >/dev/null <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.cirruslabs.tart-guest-agent</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/tart-guest-agent</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/tart-guest-agent.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/tart-guest-agent.log</string>
</dict>
</plist>
PLIST
      launchctl load "$tga_plist" 2>/dev/null || true
      log_success "Tart guest agent installed (clipboard sharing enabled)"
    else
      log_warning "Failed to download tart-guest-agent (not critical)"
    fi
    rm -rf "$tga_tmp"
  fi
fi

# =====================================================================
# Post-Installation
# =====================================================================

log_section "Post-Installation"

# Reload shell configuration
if [[ -f "${HOME}/.zshrc" && ! $DRY_RUN ]]; then
  log_info "Reloading shell configuration..."
  source "${HOME}/.zshrc" || log_warning "Failed to reload .zshrc (not critical)"
fi

# =====================================================================
# Summary
# =====================================================================

log_section "Installation Summary"

if (( ${#FAILED_SCRIPTS[@]} > 0 )); then
  log_error "Some scripts failed:"
  for script in "${FAILED_SCRIPTS[@]}"; do
    echo "  - $script"
  done
  echo ""
  log_info "You can re-run failed scripts individually:"
  for script in "${FAILED_SCRIPTS[@]}"; do
    if [[ -f "${REPO_ROOT}/${script}.zsh" ]]; then
      echo "  ./${script}.zsh"
    elif [[ -f "${REPO_ROOT}/${script}.sh" ]]; then
      echo "  ./${script}.sh"
    fi
  done
  exit 1
else
  log_success "All scripts completed successfully!"
  echo ""
  log_info "Next steps:"
  echo "  1. Restart your terminal or run: exec zsh"
  echo "  2. Verify Homebrew packages: brew list"
  echo "  3. Check symlinks: ls -la ~/ | grep '\->'"
  echo "  4. Test shell aliases and functions"
  echo ""
  log_success "✨ Dotfiles installation complete!"
fi

exit 0
