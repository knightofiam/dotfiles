# Local Testing with Tart - Quick Start

**Status:** ✅ Tart installed and ready
**Purpose:** Test dotfiles locally in clean macOS VMs for rapid iteration

---

## What You Have

- ✅ Tart 2.30.1 installed
- ✅ Helper script: `./quick-test.zsh`
- ✅ Ready to test locally

---

## Quick Start (First Time)

### Step 1: Download macOS Base Image

**One-time setup** - Downloads ~20GB macOS Sonoma base image (10-30 minutes depending on internet speed):

```bash
cd /Users/aaron/Sync/dev/projects/dotfiles

# Pull the base image
tart clone ghcr.io/cirruslabs/macos-sonoma-base:latest sonoma-base
```

This creates a clean macOS Sonoma VM you'll clone from for each test.

### Step 2: Test Your Dotfiles

```bash
# Use the helper script
./quick-test.zsh
```

The script will:
1. Create a test VM from the base (2 min)
2. Ask if you want to start it
3. You test inside the VM
4. Clean up when done

### Manual Testing (If You Prefer)

```bash
# 1. Create test VM
tart clone sonoma-base my-test

# 2. Start VM (GUI opens)
tart run my-test

# 3. Inside VM:
#    - Open Terminal
#    - git clone https://github.com/YOUR_USERNAME/dotfiles.git
#    - cd dotfiles
#    - ./install-macos.sh  # or .zsh
#    - Watch what breaks

# 4. Exit VM (Cmd+Q)

# 5. Clean up
tart delete my-test
```

---

## Your Iteration Workflow

### The Fast Loop (5-10 min per cycle)

```bash
# On your real Mac:
vim install-macos.zsh  # Make changes

# Test in clean VM:
./quick-test.zsh
# → Creates fresh VM
# → You test inside (see what breaks)
# → Exit and delete

# Fix issues:
vim install-macos.zsh

# Test again:
./quick-test.zsh

# Repeat until it works!
```

### Once Things Work

```bash
# Commit and push
git commit -am "Fix installation script"
git push

# GitHub Actions will validate on 3 macOS versions
# Check: https://github.com/YOUR_USERNAME/dotfiles/actions
```

---

## What to Test In The VM

### 1. Basic Smoke Test

```bash
# Inside VM
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles

# Try the main installation
./install-macos.sh  # or ./install-macos.zsh

# Watch for errors
```

### 2. Individual Scripts

```bash
# Test specific scripts
./brew.zsh
./shell.zsh
./symlink.zsh --dry-run
```

### 3. Check Results

```bash
# Verify things work
ls -la ~/
which brew
zsh --version
```

---

## Common VM Commands

```bash
# List all VMs
tart list

# Create VM from base
tart clone sonoma-base my-test-name

# Start VM (GUI)
tart run my-test-name

# Stop VM
tart stop my-test-name

# Delete VM
tart delete my-test-name

# Get VM IP (for SSH)
tart ip my-test-name

# SSH into running VM
ssh admin@$(tart ip my-test-name)
# Password: admin
```

---

## Disk Space Management

VMs use disk space:
- Base image: ~20GB
- Each test VM: starts at ~20GB

### Keep It Clean

```bash
# Delete test VMs after use
tart delete test-vm-name

# List all VMs and their sizes
tart list

# Delete all test VMs at once
tart list | grep test | awk '{print $1}' | xargs -n1 tart delete
```

### What to Keep

- **Keep:** `sonoma-base` (your clean template)
- **Delete:** All test VMs after use

---

## Tips & Tricks

### 1. Fast Testing Without GUI

If you don't need GUI testing (Dock, System Settings):

```bash
# Start VM without graphics (faster)
tart run --no-graphics my-test &

# Wait for boot
sleep 30

# SSH in
ssh admin@$(tart ip my-test)

# Test your dotfiles
git clone ...
cd dotfiles
./install-macos.zsh

# Exit
exit

# Clean up
tart stop my-test
tart delete my-test
```

### 2. Keep a VM for Debugging

```bash
# Create a test VM
tart clone sonoma-base debug-vm

# Test, it breaks, don't delete it
tart run debug-vm

# Later, resume debugging
tart run debug-vm

# When done
tart delete debug-vm
```

### 3. Test Multiple macOS Versions

```bash
# Create bases for different versions
tart clone ghcr.io/cirruslabs/macos-ventura-base:latest ventura-base
tart clone ghcr.io/cirruslabs/macos-sequoia-base:latest sequoia-base

# Test on Ventura
tart clone ventura-base test-ventura
tart run test-ventura

# Test on Sequoia
tart clone sequoia-base test-sequoia
tart run test-sequoia
```

### 4. Reduce DHCP Issues (Optional)

If you're running LOTS of VMs daily:

```bash
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.InternetSharing.default.plist bootpd -dict DHCPLeaseTimeSecs -int 600
```

---

## Troubleshooting

### VM Won't Start

```bash
# Check if another VM is running
tart list

# Stop all VMs
tart list | awk '{print $1}' | xargs -n1 tart stop

# Try again
```

### VM is Slow

VMs need resources. Close other apps or give VM more resources:

```bash
# Allocate more CPU/RAM
tart set my-vm --cpu 4 --memory 8192
```

### Can't SSH to VM

```bash
# Wait longer after starting
sleep 60

# Check if VM has IP
tart ip my-vm

# Check if VM is fully booted
tart list
```

### Out of Disk Space

```bash
# Check disk usage
df -h

# Delete old test VMs
tart list | grep test | awk '{print $1}' | xargs -n1 tart delete

# Only keep the base images
```

---

## Your Next Steps

1. **Download base image:** `tart clone ghcr.io/cirruslabs/macos-sonoma-base:latest sonoma-base` (do this now!)
2. **Run first test:** `./quick-test.zsh`
3. **Start fixing your dotfiles** with rapid iteration
4. **Push to GitHub** once things stabilize

---

## Comparison: Local vs CI

| | Local Testing (Tart) | CI Testing (GitHub Actions) |
|---|---|---|
| **Speed** | 5-10 min | 15-20 min |
| **Iterations** | Unlimited | Every push |
| **Interactive** | Yes (GUI) | No |
| **Multiple OS** | Manual | Automatic (3 versions) |
| **Best For** | Rapid iteration, broken code | Final validation, ongoing maintenance |

**Strategy:**
- Use **Tart** now (while dotfiles are broken)
- Use **GitHub Actions** later (once things work)

---

## Quick Reference

```bash
# First time setup
tart clone ghcr.io/cirruslabs/macos-sonoma-base:latest sonoma-base

# Each test iteration
./quick-test.zsh

# Manual control
tart clone sonoma-base test-vm
tart run test-vm
tart delete test-vm

# Cleanup
tart list | grep test | awk '{print $1}' | xargs -n1 tart delete
```

---

**You're all set! Download the base image and start testing:**

```bash
tart clone ghcr.io/cirruslabs/macos-sonoma-base:latest sonoma-base
```

(This will take 10-30 minutes - good time for a coffee break!)
