# GitHub Actions CI/CD Setup Guide

**Created:** 2026-01-20
**Purpose:** Automated testing for dotfiles on macOS and Linux

---

## Overview

Your dotfiles now have **automated CI/CD testing** that runs on every push and pull request. This ensures your dotfiles work correctly across multiple macOS and Linux versions **before** you deploy them to your production machine.

**Status:** ✅ Ready to use (just push to GitHub)

---

## What's Been Set Up

### 1. GitHub Actions Workflows

**Location:** `.github/workflows/`

- **`test-macos.yml`** - Tests on macOS Ventura, Sonoma, and Sequoia
- **`test-linux.yml`** - Tests on Ubuntu, Debian, and Fedora

### 2. Test Scripts

**Location:** `tests/`

- **`test-macos.zsh`** - Validates macOS-specific functionality
- **`test-linux.zsh`** - Validates Linux compatibility

---

## How It Works

### Automatic Triggers

Tests run automatically on:
- ✅ Every push to `master` or `main` branch
- ✅ Every pull request
- ✅ Manual trigger (workflow_dispatch)

### What Gets Tested

#### macOS Tests (3 versions)
1. **Syntax validation** - All scripts are syntactically correct
2. **Script execution** - Installation scripts can run
3. **Dry-run testing** - Installation dry-run completes without errors
4. **Configuration validation** - Brewfile and zshrc are valid
5. **Platform compatibility** - Apple Silicon paths handled correctly
6. **Custom tests** - Your test-macos.zsh script

#### Linux Tests (4 distributions)
1. **Platform detection** - Scripts detect Linux properly
2. **Package manager detection** - apt/dnf handling
3. **macOS code guards** - macOS-specific code is properly guarded
4. **Cross-platform compatibility** - No hardcoded macOS paths
5. **Custom tests** - Your test-linux.zsh script

---

## Getting Started

### Step 1: Push to GitHub

```bash
cd /Users/aaron/Sync/dev/projects/dotfiles

# Add the new files
git add .github/ tests/ *.md

# Commit
git commit -m "Add GitHub Actions CI/CD testing

- Test on macOS Ventura, Sonoma, Sequoia
- Test on Ubuntu, Debian, Fedora
- Automated validation on every push
- Custom test suites for macOS and Linux"

# Push to trigger first test run
git push origin master
```

### Step 2: Watch Tests Run

1. Go to your GitHub repository
2. Click the **"Actions"** tab
3. You'll see workflows running:
   - "Test macOS Installation"
   - "Test Linux Installation"

4. Click on a workflow to see detailed logs

### Step 3: Check Results

- ✅ **Green checkmark** = All tests passed
- ❌ **Red X** = Some tests failed
- 🟡 **Yellow dot** = Tests running

---

## Viewing Test Results

### On GitHub

**URL:** `https://github.com/YOUR_USERNAME/dotfiles/actions`

Each workflow run shows:
- Which macOS/Linux versions were tested
- Detailed logs for each step
- Summary of passed/failed tests
- Runtime duration

### Badge in README (Optional)

Add test status badges to your README:

```markdown
![macOS Tests](https://github.com/YOUR_USERNAME/dotfiles/workflows/Test%20macOS%20Installation/badge.svg)
![Linux Tests](https://github.com/YOUR_USERNAME/dotfiles/workflows/Test%20Linux%20Installation/badge.svg)
```

---

## Understanding Test Results

### All Green = Ready to Deploy

```
✓ Test macOS Installation - 3/3 passed
  ✓ macOS Ventura
  ✓ macOS Sonoma
  ✓ macOS Sequoia

✓ Test Linux Installation - 4/4 passed
  ✓ Ubuntu 22.04
  ✓ Ubuntu 24.04
  ✓ Debian 12
  ✓ Fedora 39
```

**Meaning:** Your dotfiles are safe to install on a fresh Mac or Linux system.

### Some Failed = Fix Before Deploying

```
✗ Test macOS Installation - 2/3 passed
  ✓ macOS Ventura
  ✗ macOS Sequoia - Script syntax error in brew.zsh
  ✓ macOS Sonoma
```

**Action:** Check the error logs, fix the issue, and push again. Tests will re-run automatically.

---

## Running Tests Locally

### Before Pushing to GitHub

```bash
# Test locally first
cd /Users/aaron/Sync/dev/projects/dotfiles

# Run macOS tests
./tests/test-macos.zsh

# Check syntax
zsh -n ./install-macos.zsh
zsh -n ./brew.zsh
# etc.
```

### Full Local Testing

If you want to test in a clean environment locally, use VMs:
- See `TART_TESTING_GUIDE.md` for Tart VM testing
- Or just rely on GitHub Actions (easier)

---

## Typical Workflow

### Making Changes

```bash
# 1. Make changes to your dotfiles
vim install-macos.zsh

# 2. Test syntax locally (quick)
zsh -n install-macos.zsh

# 3. Run local tests (quick)
./tests/test-macos.zsh

# 4. Commit and push
git add install-macos.zsh
git commit -m "Update installation script"
git push

# 5. Check GitHub Actions (automatic)
# Go to: https://github.com/YOUR_USERNAME/dotfiles/actions

# 6. Wait for tests to pass (5-10 minutes)

# 7. If green, deploy to your Mac with confidence!
```

### Before Upgrading macOS

```bash
# 1. Check if your dotfiles pass on the new macOS version
#    (GitHub Actions tests latest available versions)

# 2. If you see warnings about a new macOS version:
#    - GitHub may not have runners yet
#    - Use Tart VMs for testing (see TART_TESTING_GUIDE.md)
#    - Or wait for GitHub to add runners

# 3. Fix any issues found in tests

# 4. NOW upgrade your Mac safely
```

---

## What Happens If Tests Fail?

### 1. Check the Logs

Click on the failed workflow run → Click on the failed job → Read the logs

Example error:
```
✗ FAIL Script syntax is valid
  └─ Syntax error in brew.zsh line 42
```

### 2. Fix the Issue

```bash
# Fix the problem
vim brew.zsh

# Test locally
zsh -n brew.zsh
./tests/test-macos.zsh

# Push the fix
git add brew.zsh
git commit -m "Fix syntax error in brew.zsh"
git push
```

### 3. Tests Re-run Automatically

GitHub Actions will automatically test your fix. No manual intervention needed.

---

## Cost

**For public repositories:** ✅ **FREE** (unlimited)

**For private repositories:**
- Linux: FREE (unlimited)
- macOS: 2,000 free minutes/month (200 macOS minutes due to 10x multiplier)
- After free tier: $0.08/minute for macOS

**Your repo is public, so everything is free!**

---

## Customizing Tests

### Add More Test Cases

Edit `tests/test-macos.zsh` or `tests/test-linux.zsh`:

```zsh
# Example: Add a test for GPG setup
test_start "GPG configuration valid"
if gpg --list-keys 2>/dev/null; then
  test_pass
else
  test_fail "GPG not configured"
fi
```

### Test on Different OS Versions

Edit `.github/workflows/test-macos.yml`:

```yaml
matrix:
  include:
    - os: macos-12        # Add Monterey
      os-name: "Monterey"
    - os: macos-13
      os-name: "Ventura"
    # etc.
```

### Add Pre-Installation Steps

Edit the workflow to install dependencies first:

```yaml
- name: Install test dependencies
  run: |
    brew install some-tool
```

---

## Troubleshooting

### Tests Pass on GitHub but Fail Locally

**Cause:** Your local environment has pre-installed tools that a fresh Mac won't have.

**Solution:** Trust the CI tests (they're in a clean environment). Consider testing in a VM locally.

### Tests Fail on GitHub but Pass Locally

**Cause:** Your local environment has customizations not in the dotfiles.

**Solution:** Add the missing dependencies to your installation scripts.

### Workflow Doesn't Trigger

**Check:**
1. Files are in `.github/workflows/` (not `.github/workflow/`)
2. YAML syntax is valid
3. Branch name matches trigger (master vs main)

### Tests Take Too Long

**Current runtime:** ~5-10 minutes per matrix job

**If slower:**
- Check for network-intensive operations
- Consider caching Homebrew installations
- Run fewer OS versions

---

## Best Practices

### 1. Always Check CI Before Deploying

```bash
# Don't do this:
git push && ./install-macos.zsh

# Do this:
git push
# Wait for CI to pass
# Then: ./install-macos.zsh
```

### 2. Keep Tests Fast

- Use `--dry-run` when possible
- Don't install every package (just validate)
- Skip long-running operations in CI

### 3. Test Before Committing

```bash
# Quick local validation
./tests/test-macos.zsh

# Then commit
git commit
```

### 4. Use Descriptive Commit Messages

Good:
```
git commit -m "Fix Apple Silicon Homebrew path detection"
```

Bad:
```
git commit -m "update stuff"
```

### 5. Monitor Test Trends

If tests start failing frequently:
- macOS/Linux updated and broke something
- Time to update your scripts
- Check GitHub Actions logs for patterns

---

## Next Steps

1. **Push to GitHub** to trigger first test run
2. **Watch tests pass** (hopefully!)
3. **Fix any failures** that appear
4. **Continue migration** with confidence that CI will catch issues

---

## Resources

- **GitHub Actions Docs:** https://docs.github.com/en/actions
- **Workflow Syntax:** https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions
- **macOS Runners:** https://github.com/actions/runner-images/blob/main/images/macos/macos-13-Readme.md

---

## Quick Commands

```bash
# View workflows
ls -la .github/workflows/

# View test scripts
ls -la tests/

# Run tests locally
./tests/test-macos.zsh
./tests/test-linux.zsh

# Check syntax
zsh -n *.zsh

# Push and trigger CI
git push origin master

# View GitHub Actions
open "https://github.com/YOUR_USERNAME/dotfiles/actions"
```

---

## Summary

✅ **Automated testing set up**
✅ **Tests 3 macOS versions + 4 Linux distros**
✅ **Runs on every push (free for public repos)**
✅ **Prevents broken dotfiles on Mac upgrades**
✅ **5-10 minute feedback loop**

**Just push to GitHub and watch the magic happen!**

---

**Ready to push?**

```bash
cd /Users/aaron/Sync/dev/projects/dotfiles
git add .github/ tests/ *.md
git commit -m "Add GitHub Actions CI/CD testing"
git push origin master
```

Then visit: `https://github.com/YOUR_USERNAME/dotfiles/actions`
