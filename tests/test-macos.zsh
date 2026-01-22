#!/usr/bin/env zsh

# macOS Dotfiles Test Suite
# This script runs validation tests on macOS installations

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
  ((TESTS_RUN++))
  echo -n "${BLUE}[TEST $TESTS_RUN]${NC} $1... "
}

test_pass() {
  ((TESTS_PASSED++))
  echo "${GREEN}✓ PASS${NC}"
}

test_fail() {
  ((TESTS_FAILED++))
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
echo "${BLUE}macOS Dotfiles Test Suite${NC}"
echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Test 1: Check required scripts exist
test_start "Required installation scripts exist"
if [[ -f ./install-macos.zsh ]] || [[ -f ./install-macos.sh ]]; then
  test_pass
else
  test_fail "No install-macos script found"
fi

# Test 2: Check script syntax
test_start "Script syntax is valid"
syntax_ok=true
for script in *.sh *.zsh; do
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

# Test 3: Check for proper shebangs
test_start "Scripts have proper shebangs"
shebang_ok=true
for script in *.sh *.zsh; do
  if [[ -f "$script" && -x "$script" ]]; then
    first_line=$(head -n1 "$script")
    if [[ ! "$first_line" =~ ^#!/ ]]; then
      shebang_ok=false
      break
    fi
  fi
done

if $shebang_ok; then
  test_pass
else
  test_fail "Some scripts missing shebang"
fi

# Test 4: Check Brewfile exists
test_start "Brewfile exists"
if [[ -f ./Brewfile2 ]] || [[ -f ./Brewfile ]]; then
  test_pass
else
  test_fail "No Brewfile found"
fi

# Test 5: Check zsh configuration exists
test_start "Zsh configuration exists"
if [[ -f ./zsh/zshrc ]] || [[ -f ./.zshrc ]]; then
  test_pass
else
  test_fail "No zshrc found"
fi

# Test 6: Check for Apple Silicon compatibility
test_start "Apple Silicon paths handled"
has_hardcoded_paths=false
if grep -r "/usr/local/bin" . --exclude-dir=.git --exclude-dir=tests 2>/dev/null | grep -q ".*"; then
  # Check if there's also Homebrew prefix detection
  if grep -r "brew --prefix" . --exclude-dir=.git 2>/dev/null | grep -q ".*"; then
    test_pass
  else
    has_hardcoded_paths=true
    test_fail "Hardcoded /usr/local/bin without prefix detection"
  fi
else
  test_pass
fi

# Test 7: Check for macOS version detection
test_start "macOS version detection present"
if grep -r "sw_vers" . --exclude-dir=.git --exclude-dir=tests 2>/dev/null | grep -q ".*" || \
   grep -r "ProductVersion" . --exclude-dir=.git --exclude-dir=tests 2>/dev/null | grep -q ".*"; then
  test_pass
else
  test_skip "(Not required but recommended)"
fi

# Test 8: Check symlinks configuration
test_start "Symlinks configuration exists"
if [[ -f ./symlinks2 ]] || [[ -f ./symlinks ]] || [[ -f ./symlink.zsh ]]; then
  test_pass
else
  test_fail "No symlinks configuration found"
fi

# Test 9: Check for migration status
test_start "Migration status (bash → zsh)"
bash_count=$(ls -1 *.sh 2>/dev/null | wc -l | tr -d ' ')
zsh_count=$(ls -1 *.zsh 2>/dev/null | wc -l | tr -d ' ')

if [[ $bash_count -eq 0 ]]; then
  test_pass
  echo "  ${GREEN}└─ All scripts migrated to zsh${NC}"
elif [[ $zsh_count -gt $bash_count ]]; then
  test_pass
  echo "  ${YELLOW}└─ Migration in progress: $bash_count bash, $zsh_count zsh${NC}"
else
  test_fail "More bash scripts than zsh ($bash_count vs $zsh_count)"
fi

# Test 10: Check for help flags
test_start "Scripts support --help flag"
help_support=false
for script in *.zsh; do
  if [[ -f "$script" && -x "$script" ]]; then
    if ./"$script" --help 2>/dev/null | grep -q "Usage"; then
      help_support=true
      break
    fi
  fi
done

if $help_support; then
  test_pass
else
  test_skip "(Not required but recommended)"
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
