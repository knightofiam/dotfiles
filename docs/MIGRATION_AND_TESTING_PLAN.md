# Dotfiles Migration & Testing Plan

**Created:** 2026-01-20
**Purpose:** Comprehensive plan for modernizing dotfiles and implementing automated testing
**Status:** Planning Phase

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Problem Statement](#problem-statement)
3. [Current State](#current-state)
4. [Migration Strategy](#migration-strategy)
5. [Automated Testing Strategy](#automated-testing-strategy)
6. [Implementation Phases](#implementation-phases)
7. [Future Maintenance](#future-maintenance)

---

## Executive Summary

This repository is undergoing a critical modernization from Bash (macOS 10.x era) to Zsh (macOS 11+). Currently **75% of scripts remain unmigrated**, and **there is no automated testing**, leading to breakage during Mac upgrades.

**Key Objectives:**
1. Complete migration from Bash to Zsh
2. Implement automated testing in sandbox environments
3. Support both macOS and Linux
4. Ensure dotfiles work on fresh Mac setups
5. Create maintainable, version-tested infrastructure

**Timeline:** 2-3 weeks
**Priority:** HIGH - Prevents recurring breakage during Mac upgrades

---

## Problem Statement

### Core Issues

1. **Outdated Scripts:** Most scripts are Bash-based from old macOS versions
2. **No Automated Testing:** Changes break silently until the next Mac upgrade
3. **Manual Testing Only:** Time-consuming and error-prone
4. **Fragile Linux Support:** `nixit.sh` is 95 lines of brittle preprocessor code
5. **Incomplete Migration:** Mix of old (.sh) and new (.zsh) with no clear plan

### Business Impact

- **Every Mac upgrade breaks the dotfiles**
- Hours of manual debugging and fixing
- Lost productivity during machine setup
- Fear of upgrading macOS
- No confidence in changes

---

## Current State

### Migration Status

| Status | Count | % | Examples |
|--------|-------|---|----------|
| **Fully Migrated** | 4 | 25% | brew, shell, dutil, symlink |
| **Bash Only (Need Migration)** | 12 | 75% | install-macos, repos, private, dock |
| **Modern Zsh Only** | 4 | - | gpg, macos, nswag |

### Files by Category

#### ✅ Fully Migrated (Can Delete Old)
- `brew.sh` → `brew.zsh`
- `shell.sh` → `shell.zsh`
- `dutil.sh` → `dutil.zsh`
- `symlink.sh` → `symlink.zsh`

#### 🔴 Critical - Need Migration
- `install-macos.sh` (orchestrator - 50 lines)
- `nixit.sh` (Linux preprocessor - 95 lines, MOST COMPLEX)
- `repos.sh` (Git repo cloning)
- `private.sh` (Private repo setup)

#### 🟡 High Priority - Need Migration
- `dock.sh` (Dock configuration)
- `android.sh` (Android SDK)
- `mvim.sh` (MacVim setup)
- `ssh.sh` (SSH config)

#### 🟢 Low Priority - Need Migration
- `python.sh`, `rider.sh`, `gcc.sh`

#### ℹ️ No Migration Needed
- Vim configuration files (`.vimrc`, vim plugins)
- Git config (`.gitconfig`, `.gitignore`)
- Zsh configs (`zsh/zshrc`, `zsh/zprofile`, `zsh/aliases.zsh`)

---

## Migration Strategy

### Guiding Principles

1. **Delete old after migration** - If `.zsh` version exists, delete `.sh` version
2. **Keep working configs** - Don't migrate things that don't need it (vim, git configs)
3. **Linux-first design** - Build cross-platform from the start, not as an afterthought
4. **Test everything** - Automated tests prevent future breakage
5. **Document decisions** - Future Claude instances should understand why things are the way they are

### Migration Approach

#### For Each Script:

1. **Analyze Old Version**
   - What does it do?
   - What are the macOS-specific parts?
   - What breaks on new macOS versions?

2. **Study Existing Zsh Migrations**
   - `brew.zsh` - Best practices for error handling
   - `shell.zsh` - Modern macOS detection (M1/M2)
   - `symlink.zsh` - CLI flags and dry-run modes

3. **Implement New Version**
   - Use Zsh features (arrays, better string handling)
   - Add error handling and validation
   - Support macOS and Linux with platform detection
   - Add `--dry-run` flag for safety
   - Include verbose output

4. **Test Both Platforms**
   - macOS: Multiple versions (Ventura, Sonoma, Sequoia)
   - Linux: Ubuntu, Fedora, Debian

5. **Delete Old Version**
   - Only after new version is tested and working

### Cross-Platform Strategy

**Replace:** Fragile `nixit.sh` preprocessor
**With:** Native platform detection in each script

```zsh
# Example pattern
case "$(uname -s)" in
  Darwin)
    # macOS-specific code
    ;;
  Linux)
    if command -v apt-get >/dev/null; then
      # Debian/Ubuntu
    elif command -v dnf >/dev/null; then
      # Fedora/RHEL
    fi
    ;;
esac
```

**Benefits:**
- No preprocessing step
- Easier to maintain
- Better error messages
- Can test both platforms simultaneously

---

## Automated Testing Strategy

### Overview

**Goal:** Ensure dotfiles work on fresh Mac/Linux installations before deploying to production machine.

**Key Requirements:**
1. Test on clean macOS environments (no pre-installed tools)
2. Test on multiple macOS versions
3. Test on Linux distributions
4. Run automatically on every commit
5. Fast feedback (< 30 minutes)

### Testing Approaches

#### 1. GitHub Actions CI/CD (Primary - macOS Testing)

**Pros:**
- Free for public repos (or included in private repo minutes)
- Native macOS runners (Big Sur, Monterey, Ventura, Sonoma)
- Automated on every push/PR
- Matrix testing (multiple OS versions)
- No local infrastructure needed

**Cons:**
- Limited to 6 hours per job
- Can't test on exact production macOS version immediately when new OS releases

**Implementation:**

```yaml
# .github/workflows/test-dotfiles.yml
name: Test Dotfiles

on: [push, pull_request]

jobs:
  test-macos:
    strategy:
      matrix:
        os: [macos-13, macos-14, macos-15]  # Ventura, Sonoma, Sequoia
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - name: Run installation
        run: ./install-macos.zsh --dry-run
      - name: Test core functionality
        run: ./tests/test-macos.zsh
```

**Coverage:**
- Installation doesn't error
- All scripts are executable
- Dependencies are installed correctly
- Symlinks are created properly
- No broken paths or missing files

#### 2. Local VM Testing (Secondary - Full Integration)

**For testing before major Mac upgrades or releases:**

**Option A: Tart (Recommended for Apple Silicon)**
```bash
# Install Tart
brew install cirruslabs/cli/tart

# Create VM from official image
tart clone ghcr.io/cirruslabs/macos-sonoma-base:latest sonoma-test

# Run VM
tart run sonoma-test

# Inside VM, clone and test dotfiles
git clone <your-repo>
cd dotfiles
./install-macos.zsh
```

**Option B: UTM (GUI-based, easier for manual testing)**
- Download from: https://mac.getutm.app/
- Create macOS VM from IPSW
- Snapshot before testing
- Restore snapshot for clean testing

**Benefits:**
- Exact macOS version testing
- Full GUI testing (for Dock, System Settings)
- Can test upgrade scenarios
- Complete isolation

**Drawbacks:**
- Slower (30-60 min per test)
- Requires local resources
- Manual process

#### 3. Docker Testing (Linux Only)

**For Linux distribution testing:**

```dockerfile
# tests/docker/Dockerfile.ubuntu
FROM ubuntu:22.04
WORKDIR /dotfiles
COPY . .
RUN ./install-linux.zsh
CMD ["zsh", "-c", "source ~/.zshrc && echo 'Success'"]
```

```yaml
# .github/workflows/test-linux.yml
jobs:
  test-linux:
    strategy:
      matrix:
        distro: [ubuntu:22.04, ubuntu:24.04, fedora:39, debian:12]
    runs-on: ubuntu-latest
    container: ${{ matrix.distro }}
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: |
          if command -v apt-get; then
            apt-get update && apt-get install -y git zsh
          elif command -v dnf; then
            dnf install -y git zsh
          fi
      - name: Run installation
        run: ./install-linux.zsh
```

#### 4. Test Infrastructure Files

Create a `tests/` directory with:

```
tests/
├── test-macos.zsh          # macOS test suite
├── test-linux.zsh          # Linux test suite
├── test-common.zsh         # Shared test utilities
├── fixtures/               # Test data
└── docker/
    ├── Dockerfile.ubuntu
    ├── Dockerfile.fedora
    └── Dockerfile.debian
```

### Test Coverage

#### Level 1: Smoke Tests (Fast - 5 min)
- All scripts are executable
- No syntax errors
- Help flags work (`--help`, `--dry-run`)
- Platform detection works

#### Level 2: Installation Tests (Medium - 15 min)
- Dry-run completes without errors
- Dependencies are available (Homebrew, git, etc.)
- Symlinks are created correctly
- Config files are valid

#### Level 3: Integration Tests (Slow - 30 min)
- Full installation on clean system
- All tools are accessible
- Shell functions work
- Aliases are available
- GPG signing works

### Testing Schedule

- **On every commit:** Level 1 (smoke tests)
- **On PR:** Level 1 + Level 2
- **Before merge to master:** Level 1 + Level 2 + Level 3
- **Monthly:** Full VM testing on latest macOS
- **Before Mac upgrade:** Full VM testing on new macOS version

---

## Implementation Phases

### Phase 0: Testing Infrastructure (Week 1 - Priority 1)

**Goal:** Set up automated testing before migration to catch issues early

**Tasks:**
1. Create GitHub Actions workflow for macOS testing
2. Create GitHub Actions workflow for Linux testing
3. Create `tests/` directory structure
4. Write basic smoke tests
5. Document VM testing procedure
6. Create test documentation

**Deliverables:**
- `.github/workflows/test-macos.yml`
- `.github/workflows/test-linux.yml`
- `tests/test-macos.zsh`
- `tests/test-linux.zsh`
- `tests/README.md`

**Success Criteria:**
- CI passes on current state
- Can run tests locally
- VM testing documented

### Phase 1: Foundation (Week 2 - Priority 1)

**Goal:** Migrate critical orchestration scripts and enable end-to-end testing

**Tasks:**
1. Create `install-macos.zsh` (port from `install-macos.sh`)
2. Create `install-linux.zsh` (native Zsh, not preprocessing)
3. Add platform detection utilities
4. Test on GitHub Actions
5. Delete `install-macos.sh` and `nixit.sh`

**Deliverables:**
- `install-macos.zsh` (replaces `install-macos.sh`)
- `install-linux.zsh` (replaces `nixit.sh`)
- `lib/platform.zsh` (shared utilities)

**Success Criteria:**
- Can install dotfiles on fresh macOS via CI
- Can install dotfiles on fresh Linux via CI
- Old scripts deleted

### Phase 2: Core Scripts (Week 2 - Priority 2)

**Goal:** Migrate frequently-used, high-value scripts

**Tasks:**
1. Migrate `repos.zsh` (Git repo cloning)
2. Migrate `private.zsh` (Private repo setup)
3. Migrate `dock.zsh` (Dock configuration)
4. Test each script individually
5. Delete old versions

**Deliverables:**
- `repos.zsh`, `private.zsh`, `dock.zsh`
- Tests for each script
- Old versions deleted

**Success Criteria:**
- All scripts pass CI tests
- Manually verified on local machine

### Phase 3: Developer Tools (Week 3 - Priority 3)

**Goal:** Migrate remaining developer tool scripts

**Tasks:**
1. Migrate `android.zsh`, `mvim.zsh`, `ssh.zsh`
2. Migrate `python.zsh`, `rider.zsh`, `gcc.zsh`
3. Test each script
4. Delete old versions

**Deliverables:**
- All remaining `.zsh` versions
- Complete test coverage
- Old versions deleted

**Success Criteria:**
- 100% migration complete
- CI passes on all platforms
- Documentation updated

### Phase 4: Cleanup & Documentation (Week 3 - Priority 4)

**Goal:** Final cleanup and comprehensive documentation

**Tasks:**
1. Update main README with new installation process
2. Document testing procedures
3. Create troubleshooting guide
4. Archive or delete old analysis documents
5. Final end-to-end testing

**Deliverables:**
- Updated `README.md`
- `TESTING.md`
- `TROUBLESHOOTING.md`
- Clean repository structure

**Success Criteria:**
- Fresh Mac installation works perfectly
- Documentation is complete and accurate
- Repository is clean and organized

---

## Future Maintenance

### Ongoing Testing

1. **Automatic:** GitHub Actions on every commit
2. **Monthly:** Full VM testing on latest macOS
3. **Before Mac Upgrade:** Test on beta/RC versions
4. **Annual:** Review and update Homebrew packages

### Monitoring macOS Changes

- Subscribe to macOS release notes
- Test on beta versions before public release
- Update platform detection for new versions
- Watch for deprecated APIs/tools

### Adding New Tools

1. Add to appropriate Brewfile/installation script
2. Add test coverage
3. Document in README
4. Verify on CI before merging

### Breaking Changes

If Apple/Linux distros make breaking changes:
1. CI will catch them immediately
2. Fix in isolated branch
3. Test on VM before deploying
4. Update documentation

---

## Quick Start for Future Claude Instances

**If you're a future Claude Code instance working on this repository, start here:**

1. **Read this document first** - You're already doing it!
2. **Check current phase** - Look at the Implementation Phases section
3. **Run tests** - `./tests/test-macos.zsh` or check GitHub Actions
4. **Understand migration status:**
   - If `script.sh` and `script.zsh` both exist → migration complete, delete `.sh`
   - If only `script.sh` exists → needs migration
   - If only `script.zsh` exists → already modern
5. **Follow the patterns** - Study `brew.zsh`, `shell.zsh`, `symlink.zsh` for best practices
6. **Test everything** - Use CI and VM testing before deploying

---

## Appendix: Key Decisions

### Why Zsh?

- Default shell on macOS since Catalina (10.15)
- Better scripting features (arrays, associative arrays, advanced string handling)
- Better completion system
- All new scripts use Zsh

### Why Delete Old Scripts?

- Reduces confusion
- Forces full migration
- Prevents accidentally running old broken scripts
- Cleaner repository

### Why No Preprocessing (nixit.sh)?

- Fragile and hard to maintain
- Hides platform differences
- Makes debugging harder
- Native platform detection is cleaner and more maintainable

### Why GitHub Actions?

- Free and automated
- Native macOS runners
- Industry standard
- No local infrastructure needed

### Why Keep Vim/Git Configs?

- They're already platform-agnostic
- Work perfectly as-is
- No Bash/Zsh distinction
- "If it ain't broke, don't fix it"

---

## Success Metrics

**Migration Complete:**
- [ ] 0 `.sh` scripts remain (except historical backups)
- [ ] 100% of scripts are `.zsh`
- [ ] All scripts pass CI tests
- [ ] Works on fresh macOS install
- [ ] Works on Linux distros

**Testing Infrastructure:**
- [ ] GitHub Actions CI passing
- [ ] Tests run on every commit
- [ ] VM testing documented
- [ ] Can test new macOS versions before upgrading

**Documentation:**
- [ ] README updated
- [ ] Testing guide created
- [ ] Troubleshooting guide created
- [ ] Future maintainers understand the system

---

**End of Plan**

*This is a living document. Update it as work progresses and decisions are made.*
