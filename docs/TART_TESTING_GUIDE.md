# Tart VM Testing Guide for Dotfiles

**Created:** 2026-01-20
**Purpose:** Test dotfiles in clean macOS VMs using Tart before deploying to production

---

## What is Tart?

Tart is a virtualization toolset for macOS that uses Apple's native Virtualization.framework. It's:
- Fast and lightweight
- Built specifically for Apple Silicon
- Perfect for testing dotfiles on clean macOS environments
- Free and open source

**GitHub:** https://github.com/cirruslabs/tart

---

## Installation

```bash
# Install Tart
brew install cirruslabs/cli/tart

# Verify installation
tart --version
```

---

## Available macOS Images

Tart provides pre-built macOS images from Cirrus Labs:

```bash
# List available images
tart pull --help

# Common images:
# - ghcr.io/cirruslabs/macos-sonoma-base:latest (macOS 14)
# - ghcr.io/cirruslabs/macos-ventura-base:latest (macOS 13)
# - ghcr.io/cirruslabs/macos-sequoia-base:latest (macOS 15)
```

---

## Quick Start: Test Your Dotfiles

### Method 1: Automated Script (Recommended)

Use the helper script (see below for creation):

```bash
# Test on clean Sonoma VM
./tests/tart/test-vm.zsh sonoma

# Test on Ventura
./tests/tart/test-vm.zsh ventura

# Test on Sequoia
./tests/tart/test-vm.zsh sequoia
```

### Method 2: Manual Testing

```bash
# 1. Pull the base image (first time only, ~20GB download)
tart clone ghcr.io/cirruslabs/macos-sonoma-base:latest sonoma-base

# 2. Create a test VM from the base
tart clone sonoma-base dotfiles-test

# 3. Start the VM
tart run dotfiles-test

# 4. Inside the VM, test your dotfiles:
#    - Open Terminal
#    - git clone https://github.com/YOUR_USERNAME/dotfiles.git
#    - cd dotfiles
#    - ./install-macos.zsh --dry-run
#    - ./install-macos.zsh

# 5. When done, exit the VM (Cmd+Q)

# 6. Delete the test VM (it's "dirty" now)
tart delete dotfiles-test

# 7. For next test, clone from base again
tart clone sonoma-base dotfiles-test
```

---

## Best Practices

### 1. Keep a Clean Base Image

```bash
# Create your own base with common setup
tart clone ghcr.io/cirruslabs/macos-sonoma-base:latest my-sonoma-base
tart run my-sonoma-base

# Inside VM, do one-time setup:
# - Sign into iCloud (if needed for testing)
# - Install Xcode Command Line Tools
# - Any other base requirements

# Stop the VM
# Now use my-sonoma-base for all test clones
```

### 2. Use Snapshots for Quick Testing

```bash
# Not needed with Tart - cloning is fast
# Just keep a clean base and clone from it
```

### 3. Automated Testing Workflow

```bash
# 1. Make changes to dotfiles
# 2. Commit locally (don't push yet)
# 3. Run: ./tests/tart/test-vm.zsh sonoma
# 4. Script automatically:
#    - Creates fresh VM
#    - Clones your repo
#    - Runs installation
#    - Reports results
#    - Cleans up
# 5. If tests pass, push to remote
```

---

## VM Management Commands

```bash
# List all VMs
tart list

# Clone a VM
tart clone <source> <new-name>

# Start a VM (GUI)
tart run <vm-name>

# Start a VM (headless, SSH access)
tart run --no-graphics <vm-name>

# Get VM IP address
tart ip <vm-name>

# SSH into running VM
ssh admin@$(tart ip <vm-name>)
# Default password: admin

# Stop a VM (from host)
tart stop <vm-name>

# Delete a VM
tart delete <vm-name>

# Get VM info
tart get <vm-name>
```

---

## Typical Testing Workflow

### Full GUI Testing (First Time / Major Changes)

**Time: 30-45 minutes**

```bash
# 1. Create test VM
tart clone sonoma-base dotfiles-test-gui

# 2. Start with GUI
tart run dotfiles-test-gui

# 3. Inside VM:
#    - Open Terminal
#    - git clone https://github.com/YOUR_USERNAME/dotfiles.git
#    - cd dotfiles
#    - ./install-macos.zsh --dry-run
#    - Review output
#    - ./install-macos.zsh
#    - Test various features:
#      - Check Dock configuration
#      - Test shell aliases
#      - Verify symlinks
#      - Test vim setup
#      - Check GPG signing

# 4. Quit VM (Cmd+Q)

# 5. Clean up
tart delete dotfiles-test-gui
```

### Quick Automated Testing (Regular Changes)

**Time: 5-10 minutes**

```bash
# Use the automated script
./tests/tart/test-vm.zsh sonoma

# Or for multiple versions
./tests/tart/test-vm.zsh sonoma ventura sequoia
```

### CI-Style Testing (Headless)

**Time: 5-10 minutes**

```bash
# 1. Create test VM
tart clone sonoma-base dotfiles-test-headless

# 2. Start headless
tart run --no-graphics dotfiles-test-headless &

# 3. Wait for boot
sleep 30

# 4. Get IP and SSH in
VM_IP=$(tart ip dotfiles-test-headless)
ssh admin@$VM_IP << 'EOF'
  git clone https://github.com/YOUR_USERNAME/dotfiles.git
  cd dotfiles
  ./install-macos.zsh
  # Run tests
  source ~/.zshrc
  echo "Testing aliases..."
  # etc
EOF

# 5. Clean up
tart stop dotfiles-test-headless
tart delete dotfiles-test-headless
```

---

## Testing Different macOS Versions

```bash
# Create base VMs for each version you want to test
tart clone ghcr.io/cirruslabs/macos-ventura-base:latest ventura-base
tart clone ghcr.io/cirruslabs/macos-sonoma-base:latest sonoma-base
tart clone ghcr.io/cirruslabs/macos-sequoia-base:latest sequoia-base

# Test on all versions
for version in ventura sonoma sequoia; do
  echo "Testing on $version..."
  ./tests/tart/test-vm.zsh $version
done
```

---

## Disk Space Management

Tart VMs can use significant disk space:

```bash
# Check VM sizes
tart list
# Shows disk usage per VM

# Clean up old test VMs
tart list | grep test | awk '{print $1}' | xargs -n1 tart delete

# Base images are ~20GB each
# Test VMs start at ~20GB and grow with use

# Free up space by keeping only:
# - One base image per macOS version you test
# - Delete test VMs after each run
```

---

## Troubleshooting

### VM won't start
```bash
# Check if another VM is running
tart list

# Check system resources
# Tart needs: ~4GB RAM per VM, disk space

# Try stopping all VMs
tart list | awk '{print $1}' | xargs -n1 tart stop
```

### Can't connect via SSH
```bash
# Wait longer after starting VM
sleep 60

# Check if VM is running
tart list

# Check if VM has IP
tart ip <vm-name>

# If no IP, VM might not be fully booted
```

### Download is slow
```bash
# Base images are ~20GB
# First download takes time (10-30 min depending on connection)
# Subsequent clones are fast (1-2 min)

# Progress not showing? Check:
tart pull ghcr.io/cirruslabs/macos-sonoma-base:latest
```

### VM is slow
```bash
# Allocate more resources
tart set <vm-name> --cpu 4 --memory 8192

# Default is usually 2 CPU / 4GB RAM
```

---

## Integration with Your Workflow

### Before Committing Changes

```bash
# 1. Edit dotfiles
vim install-macos.zsh

# 2. Test locally first (quick check)
./install-macos.zsh --dry-run

# 3. Test in clean VM (full validation)
./tests/tart/test-vm.zsh sonoma

# 4. If passes, commit and push
git add install-macos.zsh
git commit -m "Update installation script"
git push
```

### Before macOS Upgrade

```bash
# Test on new macOS version BEFORE upgrading your real Mac

# 1. Pull new macOS base (when available)
tart clone ghcr.io/cirruslabs/macos-sequoia-base:latest sequoia-base

# 2. Test your dotfiles on it
./tests/tart/test-vm.zsh sequoia

# 3. Fix any issues found

# 4. NOW upgrade your real Mac with confidence
```

### Regular Maintenance

```bash
# Weekly: Test on latest macOS
./tests/tart/test-vm.zsh sonoma

# Monthly: Test on all supported versions
./tests/tart/test-vm.zsh ventura sonoma sequoia

# After Homebrew updates: Test installations
brew update && brew upgrade
./tests/tart/test-vm.zsh sonoma

# Clean up test VMs
tart list | grep test | awk '{print $1}' | xargs -n1 tart delete
```

---

## Comparison: Tart vs GitHub Actions

| Feature | Tart (Local) | GitHub Actions |
|---------|--------------|----------------|
| **Cost** | Free | Free (public repos) |
| **Speed** | Fast (local) | 5-15 min queue + run |
| **Control** | Full control | Limited |
| **GUI Testing** | ✅ Yes | ❌ No |
| **Automation** | Manual/scripted | Fully automated |
| **Disk Space** | Uses local disk | No local impact |
| **Internet Required** | Only for clone | Yes |
| **Multiple OS** | Sequential | Parallel |

**Recommendation:**
- **Tart:** Quick local testing, GUI testing, pre-commit validation
- **GitHub Actions:** Automated testing on every push, matrix testing

Use both! Tart for development, GitHub Actions for CI/CD.

---

## Advanced: Automated Test Script

See `tests/tart/test-vm.zsh` for a fully automated testing script that:
1. Creates fresh VM from base
2. Starts VM (headless)
3. Clones your dotfiles repo
4. Runs installation
5. Validates installation
6. Reports results
7. Cleans up VM

---

## Resources

- **Tart GitHub:** https://github.com/cirruslabs/tart
- **Tart Documentation:** https://tart.run
- **Base Images:** https://github.com/orgs/cirruslabs/packages?tab=packages&q=macos

---

## Quick Reference Card

```bash
# Setup (one time)
brew install cirruslabs/cli/tart
tart clone ghcr.io/cirruslabs/macos-sonoma-base:latest sonoma-base

# Test dotfiles (every change)
tart clone sonoma-base dotfiles-test
tart run dotfiles-test
# Test inside VM
tart delete dotfiles-test

# Or use automation
./tests/tart/test-vm.zsh sonoma

# Cleanup
tart list | grep test | awk '{print $1}' | xargs -n1 tart delete
```

---

**Next Steps:**
1. Install Tart: `brew install cirruslabs/cli/tart`
2. Pull base image: `tart clone ghcr.io/cirruslabs/macos-sonoma-base:latest sonoma-base`
3. Create automated test script: See `tests/tart/test-vm.zsh`
4. Test your dotfiles!
