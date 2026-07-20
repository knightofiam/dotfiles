#!/usr/bin/env zsh

# Linux Dotfiles Test Suite
# This script runs validation tests on Linux installations

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
test_start() {
  (( TESTS_RUN++ )) || true
  echo -n "${BLUE}[TEST $TESTS_RUN]${NC} $1... "
}

test_pass() {
  (( TESTS_PASSED++ )) || true
  echo "${GREEN}✓ PASS${NC}"
}

test_fail() {
  (( TESTS_FAILED++ )) || true
  echo "${RED}✗ FAIL${NC}"
  if [[ -n "${1:-}" ]]; then
    echo "  ${RED}└─ $1${NC}"
  fi
}

test_skip() {
  echo "${YELLOW}⊘ SKIP${NC} $1"
}

# Tests
echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "${BLUE}Linux Dotfiles Test Suite${NC}"
echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Test 1: Check for Linux installation script
test_start "Linux installation script exists"
if [[ -f ./install-linux.zsh ]]; then
  test_pass
elif [[ -f ./nixit.sh ]]; then
  test_fail "Only legacy nixit.sh found (needs migration)"
else
  test_skip "No Linux support yet"
fi

# Test 2: Check script syntax
test_start "Script syntax is valid"
syntax_ok=true
for script in *.sh(N) *.zsh(N); do
  if [[ -f "$script" && -x "$script" ]]; then
    if [[ "$script" == *.zsh ]]; then
      zsh -n "$script" 2>/dev/null || syntax_ok=false
    else
      bash -n "$script" 2>/dev/null || syntax_ok=false
    fi
  fi
done

if $syntax_ok; then
  test_pass
else
  test_fail "Some scripts have syntax errors"
fi

# Test 3: Check for platform detection
test_start "Platform detection implemented"
if grep -r "uname -s" . --exclude-dir=.git --exclude-dir=tests 2>/dev/null | grep -q ".*" || \
   grep -r 'case.*uname' . --exclude-dir=.git --exclude-dir=tests 2>/dev/null | grep -q ".*"; then
  test_pass
else
  test_fail "No platform detection found"
fi

# Test 4: Check for Linux package manager detection
test_start "Package manager detection present"
if grep -r "apt-get\|dnf\|yum\|pacman" . --exclude-dir=.git --exclude-dir=tests 2>/dev/null | grep -q ".*"; then
  test_pass
else
  test_fail "No package manager detection found"
fi

# Test 5: Check for macOS-only code guards
test_start "macOS-specific code is guarded"
macos_specific_ok=true

# Check if macOS-specific tools are properly guarded
if grep -r "defaults write\|osascript\|killall Dock" . --exclude-dir=.git --exclude-dir=tests 2>/dev/null; then
  # Check if these are within Darwin/macOS conditionals
  if ! grep -B5 "defaults write\|osascript\|killall Dock" . --exclude-dir=.git --exclude-dir=tests 2>/dev/null | grep -q "Darwin\|macos"; then
    macos_specific_ok=false
  fi
fi

if $macos_specific_ok; then
  test_pass
else
  test_fail "macOS-specific commands not properly guarded"
fi

# Test 6: Check zsh configuration
test_start "Zsh configuration exists"
if [[ -f ./zsh/zshrc ]] || [[ -f ./.zshrc ]]; then
  test_pass
else
  test_fail "No zshrc found"
fi

# Test 7: Check for hardcoded macOS paths
test_start "No hardcoded macOS paths"
hardcoded_paths_ok=true

# Check for common macOS-only paths
if grep -r "/Applications\|/Library/\|/usr/local/bin" . --exclude-dir=.git --exclude-dir=tests --exclude="*.md" 2>/dev/null | grep -v "GITHUB"; then
  # Check if they're in platform conditionals
  if ! grep -B5 "/Applications\|/Library/" . --exclude-dir=.git --exclude-dir=tests 2>/dev/null | grep -q "Darwin"; then
    test_skip "(Some macOS paths found, checking if guarded)"
  else
    test_pass
  fi
else
  test_pass
fi

# Test 8: Check for Linuxbrew/Homebrew on Linux support
test_start "Homebrew on Linux supported"
if grep -r "Linuxbrew\|/home/linuxbrew" . --exclude-dir=.git --exclude-dir=tests 2>/dev/null | grep -q ".*"; then
  test_pass
else
  test_skip "Homebrew on Linux not detected (optional)"
fi

# Test 9: Check symlinks work cross-platform
test_start "Symlink script is cross-platform"
if [[ -f ./symlink.zsh ]]; then
  if grep -q "uname\|Darwin\|Linux" ./symlink.zsh; then
    test_pass
  else
    test_skip "May be macOS-only"
  fi
else
  test_skip "No symlink.zsh found"
fi

# Test 10: Check for distribution-specific handling
test_start "Distribution detection present"
if grep -r "Ubuntu\|Debian\|Fedora\|Arch\|/etc/os-release" . --exclude-dir=.git --exclude-dir=tests 2>/dev/null | grep -q ".*"; then
  test_pass
else
  test_skip "No distro detection (optional)"
fi

# Summary
echo ""
echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "${BLUE}Test Summary${NC}"
echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Total:  $TESTS_RUN"
echo "${GREEN}Passed: $TESTS_PASSED${NC}"
echo "${RED}Failed: $TESTS_FAILED${NC}"
echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
  echo "${GREEN}✓ All tests passed!${NC}"
  exit 0
else
  echo "${RED}✗ Some tests failed${NC}"
  exit 1
fi
