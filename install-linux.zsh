#!/usr/bin/env zsh
# install-linux.zsh — orchestrates dotfiles installation on Linux
# Replaces the old nixit.sh preprocessor with native platform detection

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

Install and configure dotfiles on Linux.

OPTIONS:
  --dry-run        Show what would be done without making changes
  --skip-private   Skip private repository setup
  --help           Show this help message

EXAMPLES:
  $0                    # Full installation
  $0 --dry-run          # Preview changes
  $0 --skip-private     # Skip private repos setup

SUPPORTED DISTRIBUTIONS:
  - Ubuntu / Debian (apt)
  - Fedora / RHEL / CentOS (dnf/yum)

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
    Linux)
      echo "linux"
      ;;
    Darwin)
      echo "macos"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

detect_distro() {
  if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    echo "${ID:-unknown}"
  elif command -v lsb_release >/dev/null 2>&1; then
    lsb_release -is | tr '[:upper:]' '[:lower:]'
  else
    echo "unknown"
  fi
}

detect_package_manager() {
  if command -v apt-get >/dev/null 2>&1; then
    echo "apt"
  elif command -v dnf >/dev/null 2>&1; then
    echo "dnf"
  elif command -v yum >/dev/null 2>&1; then
    echo "yum"
  else
    echo "unknown"
  fi
}

PLATFORM="$(detect_platform)"
DISTRO="$(detect_distro)"
PKG_MGR="$(detect_package_manager)"

if [[ "$PLATFORM" != "linux" ]]; then
  echo "${RED}Error: This script is for Linux only.${NC}" >&2
  echo "For macOS, use: ./install-macos.zsh" >&2
  exit 1
fi

if [[ "$PKG_MGR" == "unknown" ]]; then
  echo "${RED}Error: Could not detect package manager (apt/dnf/yum).${NC}" >&2
  echo "Supported distributions: Ubuntu, Debian, Fedora, RHEL, CentOS" >&2
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
    # Export Linux-specific environment variables
    export LINUX_DISTRO="$DISTRO"
    export LINUX_PKG_MGR="$PKG_MGR"

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

# Install system packages
install_system_packages() {
  log_info "Installing base system packages..."

  local packages=""

  case "$PKG_MGR" in
    apt)
      packages="build-essential curl file git zsh"
      if ! $DRY_RUN; then
        sudo apt-get update
        sudo apt-get install -y $packages
      else
        log_info "[DRY RUN] Would run: sudo apt-get install -y $packages"
      fi
      ;;
    dnf|yum)
      packages="@development-tools curl file git zsh"
      if ! $DRY_RUN; then
        sudo $PKG_MGR check-update || true
        sudo $PKG_MGR install -y $packages
      else
        log_info "[DRY RUN] Would run: sudo $PKG_MGR install -y $packages"
      fi
      ;;
  esac

  log_success "Base system packages installed"
}

# =====================================================================
# Pre-Installation Checks
# =====================================================================

log_section "Pre-Installation Checks"

log_info "Platform: Linux"
log_info "Distribution: $DISTRO"
log_info "Package Manager: $PKG_MGR"
log_info "Repository: $REPO_ROOT"

# Check if zsh is available
if ! command -v zsh >/dev/null 2>&1; then
  log_warning "zsh not installed - will be installed"
fi

# =====================================================================
# Installation Sequence
# =====================================================================

log_section "Starting Installation"

# Track failures
typeset -a FAILED_SCRIPTS

# 0. Install base system packages
install_system_packages || FAILED_SCRIPTS+=("system-packages")

# 1. Homebrew (Linuxbrew - required for many packages)
run_script "brew" "Homebrew (Linuxbrew) installation" || FAILED_SCRIPTS+=("brew")

# 2. Shell setup (zsh)
run_script "shell" "Shell configuration (zsh)" || FAILED_SCRIPTS+=("shell")

# 3. Development tools
run_script "gcc" "GCC compiler setup" || FAILED_SCRIPTS+=("gcc")
run_script "python" "Python environment setup" || FAILED_SCRIPTS+=("python")
run_script "android" "Android SDK setup" || FAILED_SCRIPTS+=("android")

# 4. GPG & signing
run_script "gpg" "GPG configuration" || FAILED_SCRIPTS+=("gpg")

# 5. SSH configuration
run_script "ssh" "SSH keys & configuration" || FAILED_SCRIPTS+=("ssh")

# 6. Editor setup (vim, skip macOS-specific mvim)
log_skip "MacVim (macOS-only, skipping on Linux)"
log_skip "JetBrains Rider (macOS-only config, skipping on Linux)"

# 7. Skip macOS-specific scripts
log_skip "dutil (macOS-only, skipping on Linux)"
log_skip "Dock configuration (macOS-only, skipping on Linux)"
log_skip "macOS system preferences (macOS-only, skipping on Linux)"

# 8. Git repositories
run_script "repos" "Clone development repositories" || FAILED_SCRIPTS+=("repos")

# 9. Private repositories (optional)
if $SKIP_PRIVATE; then
  log_skip "Private repository setup (--skip-private flag used)"
else
  run_script "private" "Private repository & secrets setup" || FAILED_SCRIPTS+=("private")
fi

# 10. Symlink dotfiles (last, so configs are ready)
run_script "symlink" "Create dotfile symlinks" || FAILED_SCRIPTS+=("symlink")

# =====================================================================
# Post-Installation
# =====================================================================

log_section "Post-Installation"

# Set zsh as default shell if not already
if [[ "${SHELL:-}" != *"zsh"* && ! $DRY_RUN ]]; then
  if command -v zsh >/dev/null 2>&1; then
    log_info "Setting zsh as default shell..."
    local zsh_path="$(command -v zsh)"

    # Add to /etc/shells if not present
    if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
      echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    # Change shell
    chsh -s "$zsh_path" || log_warning "Failed to change shell (you may need to do this manually)"
  fi
fi

# Reload shell configuration
if [[ -f "${HOME}/.zshrc" && ! $DRY_RUN ]]; then
  log_info "Shell configuration ready (restart terminal to apply)"
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
  echo "  2. Verify Homebrew: brew --version"
  echo "  3. Check symlinks: ls -la ~/ | grep '\->'"
  echo "  4. Test shell aliases and functions"
  echo ""
  log_success "✨ Dotfiles installation complete!"
  echo ""
  log_info "Note: Some features are macOS-only and were skipped:"
  echo "  - Dock configuration"
  echo "  - dutil (file associations)"
  echo "  - macOS system preferences"
  echo "  - MacVim (use vim instead)"
fi

exit 0
