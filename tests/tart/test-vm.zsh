#!/usr/bin/env zsh

# Automated Dotfiles Testing with Tart VMs
# Usage: ./test-vm.zsh [ventura|sonoma|sequoia] [--keep-vm]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MACOS_VERSION="${1:-sonoma}"
KEEP_VM="${2:-}"
VM_NAME="dotfiles-test-${MACOS_VERSION}-$$"
BASE_VM="${MACOS_VERSION}-base"
TEST_TIMEOUT=600  # 10 minutes

# GitHub repo (update this to your repo)
REPO_URL="https://github.com/YOUR_USERNAME/dotfiles.git"

# Map version to image
case "$MACOS_VERSION" in
  ventura)
    IMAGE="ghcr.io/cirruslabs/macos-ventura-base:latest"
    ;;
  sonoma)
    IMAGE="ghcr.io/cirruslabs/macos-sonoma-base:latest"
    ;;
  sequoia)
    IMAGE="ghcr.io/cirruslabs/macos-sequoia-base:latest"
    ;;
  *)
    echo "${RED}Error: Unknown macOS version '$MACOS_VERSION'${NC}"
    echo "Usage: $0 [ventura|sonoma|sequoia] [--keep-vm]"
    exit 1
    ;;
esac

# Helper functions
log_info() {
  echo "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo "${RED}[ERROR]${NC} $1"
}

cleanup() {
  if [[ "$KEEP_VM" != "--keep-vm" ]]; then
    log_info "Cleaning up VM: $VM_NAME"
    tart stop "$VM_NAME" 2>/dev/null || true
    tart delete "$VM_NAME" 2>/dev/null || true
  else
    log_warning "VM kept for inspection: $VM_NAME"
    log_info "To connect: tart run $VM_NAME"
    log_info "To delete: tart delete $VM_NAME"
  fi
}

# Trap cleanup on exit
trap cleanup EXIT INT TERM

# Main script
main() {
  log_info "Starting dotfiles testing on macOS $MACOS_VERSION"
  log_info "VM name: $VM_NAME"

  # Check if tart is installed
  if ! command -v tart &> /dev/null; then
    log_error "Tart is not installed"
    log_info "Install with: brew install cirruslabs/cli/tart"
    exit 1
  fi

  # Check if base VM exists, if not pull it
  if ! tart list | grep -q "^${BASE_VM}"; then
    log_info "Base VM not found, pulling from registry..."
    log_warning "This is a ~20GB download and may take 10-30 minutes"
    tart clone "$IMAGE" "$BASE_VM"
    log_success "Base VM created: $BASE_VM"
  else
    log_info "Using existing base VM: $BASE_VM"
  fi

  # Clone base VM to create test VM
  log_info "Creating test VM from base..."
  tart clone "$BASE_VM" "$VM_NAME"
  log_success "Test VM created: $VM_NAME"

  # Start VM in headless mode
  log_info "Starting VM (headless)..."
  tart run --no-graphics "$VM_NAME" &
  VM_PID=$!

  # Wait for VM to boot and get IP
  log_info "Waiting for VM to boot (may take 30-60 seconds)..."
  sleep 30

  local retry_count=0
  local max_retries=12  # 12 * 5 = 60 seconds
  local vm_ip=""

  while [[ $retry_count -lt $max_retries ]]; do
    vm_ip=$(tart ip "$VM_NAME" 2>/dev/null || echo "")
    if [[ -n "$vm_ip" ]]; then
      log_success "VM is ready at IP: $vm_ip"
      break
    fi
    log_info "Waiting for IP address... (attempt $((retry_count + 1))/$max_retries)"
    sleep 5
    ((retry_count++))
  done

  if [[ -z "$vm_ip" ]]; then
    log_error "Failed to get VM IP address after $max_retries attempts"
    exit 1
  fi

  # Wait a bit more for SSH to be ready
  log_info "Waiting for SSH to be ready..."
  sleep 10

  # Test SSH connection
  log_info "Testing SSH connection..."
  if ! ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 admin@"$vm_ip" "echo 'SSH connected'" 2>/dev/null; then
    log_error "Failed to connect via SSH"
    log_info "Try manually: ssh admin@$vm_ip (password: admin)"
    exit 1
  fi
  log_success "SSH connection established"

  # Run dotfiles installation test
  log_info "Cloning dotfiles repository..."

  # Create test script to run inside VM
  local test_script=$(cat <<'VMSCRIPT'
set -euo pipefail

# Clone repo
echo "Cloning repository..."
if ! git clone REPO_URL ~/dotfiles; then
  echo "Failed to clone repository"
  exit 1
fi

cd ~/dotfiles

# Test dry-run first
echo "Running installation (dry-run)..."
if [[ -f ./install-macos.zsh ]]; then
  if ! ./install-macos.zsh --dry-run; then
    echo "Dry-run failed"
    exit 1
  fi
  echo "Dry-run succeeded"
else
  echo "Warning: install-macos.zsh not found, checking for install-macos.sh..."
  if [[ -f ./install-macos.sh ]]; then
    if ! ./install-macos.sh --dry-run 2>/dev/null || ! ./install-macos.sh; then
      echo "Installation check failed"
      exit 1
    fi
  else
    echo "No installation script found"
    exit 1
  fi
fi

# Run actual installation (optional - uncomment to test full install)
# echo "Running full installation..."
# ./install-macos.zsh

echo "All tests passed!"
exit 0
VMSCRIPT
)

  # Replace REPO_URL in script
  test_script="${test_script//REPO_URL/$REPO_URL}"

  # Execute test script on VM
  log_info "Running dotfiles installation tests..."
  if ssh -o StrictHostKeyChecking=no admin@"$vm_ip" "$test_script" 2>&1; then
    log_success "✓ All tests passed on macOS $MACOS_VERSION!"
    return 0
  else
    log_error "✗ Tests failed on macOS $MACOS_VERSION"
    return 1
  fi
}

# Run main function
if main; then
  log_success "Testing completed successfully!"
  exit 0
else
  log_error "Testing failed!"
  exit 1
fi
