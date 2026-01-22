# Dotfiles Repository - Executive Summary

## Quick Overview

This is a **macOS/Linux dotfiles repository** undergoing systematic migration from **Bash (v1)** to **Zsh (v2)**.

- **Location:** `/Users/aaron/Sync/dev/projects/dotfiles`
- **Git Status:** Clean (master branch)
- **Last Update:** Jan 20, 2026 (Open .bat files in MacVim)

---

## Key Numbers at a Glance

| Metric | Count | Status |
|--------|-------|--------|
| Total root shell scripts | 22 files | 16 bash + 6 zsh |
| Scripts fully migrated | 4 | brew, shell, dutil, symlink |
| Scripts still bash-only | 12 | Need migration |
| Configuration files | 3 | Have v2 versions |
| Test coverage | 0 | None found |
| Migration progress | ~30% | 4/13 core scripts done |

---

## The Big Picture

### What This Repository Does

1. **Configuration Management** - Symlinks all personal dotfiles (~/.vimrc, ~/.zshrc, etc.)
2. **System Setup** - Automated macOS/Linux installation scripts
3. **Developer Tools** - Vim, Git, SSH, Homebrew, Python, Android SDK, etc.
4. **Shell Configuration** - Bash aliases/completions and new Zsh environment
5. **GPG & Signing** - 1Password integration for Git commit signing

### Current Architecture

```
install-macos.sh (bash)              install-linux.sh (bash)
     ↓                                      ↓
  Calls 16 scripts in sequence         nixit.sh (preprocessor)
  - Some .sh (old)                     ├─ Detects Linux distro
  - Some .zsh (new)                    ├─ Modifies all scripts
  - Mixed environment                  └─ Then runs install-macos.sh
```

### What Happens When You Run It

**On macOS:** `./install-macos.sh` installs Homebrew, Xcode tools, configures shell, sets up GPG signing, customizes macOS settings, symlinks dotfiles, and clones development repos.

**On Linux:** `./install-linux.sh` → `nixit.sh` (adapts everything for Linux) → modified `install-macos.sh`

---

## Migration Status by Category

### Fully Migrated (Both .sh and .zsh exist)

| Script | Purpose | Status |
|--------|---------|--------|
| brew.sh / brew.zsh | Homebrew installation | ✅ Complete |
| shell.sh / shell.zsh | Shell & Touch ID setup | ✅ Complete |
| dutil.sh / dutil.zsh | File type associations | ✅ Complete |
| symlink.sh / symlink.zsh | Dotfile symlinking | ✅ Complete |

**Key Improvement:** New .zsh versions have better error handling, support for Apple Silicon, and enhanced features (--dry-run, --prune flags).

### Still Bash-Only (Need Zsh versions)

**CRITICAL:**
- `install-macos.sh` - Orchestrator (can't call .zsh scripts from bash)
- `nixit.sh` - 95-line Linux preprocessor (complex!)

**HIGH:**
- `shell.sh` - Now redundant (shell.zsh exists)
- `repos.sh` - Git repo setup

**MEDIUM:**
- `private.sh`, `dock.sh`, `android.sh`, `mvim.sh`, `ssh.sh`

**LOW:**
- `python.sh`, `rider.sh`, `gcc.sh`

### Zsh-Only (Already Modern)

- `gpg.zsh` - 1Password GPG integration (120 lines, sophisticated)
- `macos.zsh` - macOS system tweaks (150 lines, Sequoia-safe)
- `nswag.zsh` - NSwag API generation (small utility)
- `vim/update-plugins.zsh` - Vim plugin manager

---

## Configuration File Evolution

### The "v2" Pattern

The project uses a **v2 naming scheme** for modernized configurations:

| Purpose | v1 (Old) | v2 (New) |
|---------|----------|----------|
| Homebrew packages | `Brewfile` | `Brewfile2` |
| Symlink mappings | `symlinks` | `symlinks2` |
| File associations | `dutil` | `dutil2` |

**Why?** Backward compatibility. Old versions stay, new versions are cleaner/better.

### New Zsh Configuration Files

Created for better organization:
- `zsh/zshrc` → symlinked to `~/.zshrc` (runtime config)
- `zsh/zprofile` → symlinked to `~/.zprofile` (login config)
- `zsh/aliases.zsh` → symlinked to `~/.zsh/aliases.zsh` (aliases)

### Legacy Bash Configs (Still Active)

- `bash_profile` - Still sourced by install-macos.sh
- `bash_aliases` - Large file (~200 lines of git aliases)

---

## The nixit.sh Script - A Special Case

**What is it?** A preprocessing script that **modifies the entire dotfiles repository for Linux compatibility.**

**How does it work?**
1. Detects Linux package manager (rpm/deb)
2. Deletes 10 macOS-specific files
3. Uses sed/grep to modify scripts for Linux package managers
4. Adapts Brewfile for Linux
5. Removes Touch ID code from shell.sh
6. Installs 1Password CLI from Linux repo

**Example transformations:**
```bash
# Before: macOS specific
/usr/bin/sed -i.bak '2i auth       sufficient     pam_tid.so' /etc/pam.d/sudo

# After: Linux generic (removed)
# Touch ID code is deleted entirely
```

**Why this matters:** This is the most complex script to migrate to Zsh because it contains 95 lines of sophisticated sed/grep transformations.

---

## What's Been Improved in Zsh Versions

### Example: shell.sh vs shell.zsh

**shell.sh (Bash, basic):**
```bash
# Simple check - just modifies /etc/shells and /etc/pam.d/sudo directly
brew_prefix="/usr/local"
[[ $(grep -L "auth pam_tid.so" /etc/pam.d/sudo) ]] && sudo gsed -i.bak '2i auth       sufficient     pam_tid.so' /etc/pam.d/sudo
```

**shell.zsh (Zsh, modern):**
```bash
# Sophisticated checks:
- Detects Brew prefix (handles M1/M2 Macs with /opt/homebrew)
- Checks for Touch ID hardware first
- Creates /etc/pam.d/sudo_local instead of modifying sudo directly
- Sets sudo timeout to 15 minutes
- Better error handling and idempotency
- ~110 lines of well-documented code
```

### Example: symlink.sh vs symlink.zsh

**symlink.sh (Bash):**
- Reads `symlinks` file (raw format)
- Uses `gmv` for backups
- ~40 lines

**symlink.zsh (Zsh):**
- Reads `symlinks2` file (cleaner format)
- Supports `--dry-run` flag to preview changes
- Supports `--prune` flag to remove stale symlinks
- Auto-detects git repo root
- ~100 lines with better documentation

---

## What Gets Installed/Configured

### Homebrew Packages (Brewfile2)

Installs through `brew bundle`:
- Core: `git`, `vim`, `zsh`, `python`, `gnupg`
- Tools: `gh`, `act`, `awscli`, `git-lfs`, `dutil`
- IDEs: `macvim`, `rider`
- Apps: `iterm2`, `firefox`, `signal`, `vlc`, `zoom`
- 1Password integration: `1password-cli`, `pinentry-mac`

### Configuration Symlinks (symlinks2)

Creates symbolic links from repo to home directory:
```
~/.zshrc            <- zsh/zshrc
~/.zprofile         <- zsh/zprofile
~/.zsh/aliases.zsh  <- zsh/aliases.zsh
~/.vimrc            <- vim/vimrc
~/.vim              <- vim/
~/.gitconfig        <- git/gitconfig
~/.ssh/config       <- ssh/config
```

### System Configuration (macos.zsh)

- Keyboard repeat rates (fastest allowed)
- Trackpad force click disable
- Caps Lock to Escape mapping
- Power management settings
- Full keyboard navigation

### File Type Associations (dutil2)

Sets default applications for file types:
- .md, .json, .yaml, .sh, .zsh → MacVim
- .bat files → MacVim
- .mp3 → VLC
- .rar → The Unarchiver

---

## Installation Flow Diagram

### Current Workflow (Mixed)

```
User runs: ./install-macos.sh
           ↓
Sourced: bash_profile (PATH, exports)
           ↓
Sequential script execution:
├─ macos.sh (bash) .................. system tweaks
├─ brew.sh (bash) OR brew.zsh ....... Homebrew (can choose)
├─ xcode.sh (bash) .................. Xcode CLT
├─ gcc.sh (bash) .................... GCC
├─ shell.sh (bash) OR shell.zsh ..... Shell + Touch ID
├─ dutil.sh (bash) OR dutil.zsh ..... File associations
├─ dock.sh (bash) ................... Dock customization
├─ gpg.sh (bash) OR gpg.zsh ........ GPG setup
├─ iterm2.sh (bash) ................ iTerm2
├─ mvim.sh (bash) .................. MacVim
├─ repos.sh (bash) .................. Repositories
├─ rider.sh (bash) .................. Rider IDE
├─ ssh.sh (bash) .................... SSH config
├─ symlink.sh (bash) OR symlink.zsh  Symlinks (chooses symlinks or symlinks2)
├─ python.sh (bash) ................ Python env
└─ private.sh (bash) ................ Private config
```

### Problem: Mixed Shell Environment

The orchestrator (`install-macos.sh`) is Bash, but it can call either Bash or Zsh scripts. This creates inconsistency and makes error handling difficult.

### Target Workflow (Post-migration)

```
User runs: ./install-macos.zsh
           ↓
All scripts are Zsh (consistent environment)
Better error handling & features
```

---

## Directory Organization

```
/Users/aaron/Sync/dev/projects/dotfiles/
├── README.md                 # Installation instructions
├── Brewfile / Brewfile2       # Homebrew packages
├── bash_profile / bash_aliases # Legacy bash config
│
├── *.sh files (12 bash scripts needing migration)
│   ├── install-macos.sh      # Main orchestrator
│   ├── install-linux.sh      # Linux wrapper
│   ├── nixit.sh              # Linux preprocessor (95 lines!)
│   └── ... 9 more setup scripts
│
├── *.zsh files (6 zsh scripts - new/migrated)
│   ├── brew.zsh / shell.zsh / symlink.zsh / dutil.zsh (migrated pairs)
│   ├── gpg.zsh / macos.zsh (new zsh-only)
│   └── vim/update-plugins.zsh
│
├── zsh/                       # New Zsh configs
│   ├── zshrc                 # Zsh runtime
│   ├── zprofile              # Zsh login
│   └── aliases.zsh           # Zsh aliases
│
├── vim/                       # Vim configuration
│   ├── vimrc
│   ├── pack/plugins/         # Vim plugins
│   ├── spell/                # Spell checking
│   └── update-plugins.zsh    # Plugin manager
│
├── git/                       # Git config
│   ├── gitconfig
│   ├── gitignore_global
│   └── gitattributes_global
│
├── ssh/                       # SSH config
│   └── config
│
├── config/                    # XDG config apps
│   ├── gh/                   # GitHub CLI
│   ├── iterm2/               # iTerm2
│   ├── op/                   # 1Password
│   └── ...
│
└── [other files]
    ├── symlinks / symlinks2   # Target ← source mappings
    ├── dutil / dutil2         # File associations
    ├── cvimrc, ideavimrc      # Editor configs
    └── ...
```

---

## Key Insights

### What's Working Well

1. **Staged Migration Approach** - Old and new versions coexist, allowing gradual transition
2. **Quality Improvements** - New .zsh scripts are notably better (error handling, documentation)
3. **Configuration Modernization** - v2 files (Brewfile2, symlinks2, dutil2) are cleaner
4. **Linux Support** - Sophisticated nixit.sh preprocessor handles cross-platform
5. **Apple Silicon Ready** - Newer scripts detect /opt/homebrew vs /usr/local

### What Needs Work

1. **Orchestrator Not Updated** - install-macos.sh still calls .sh scripts (should call .zsh)
2. **Incomplete Migration** - Only 25% of core scripts migrated
3. **Complex Preprocessor** - nixit.sh is 95 lines of tricky sed/grep (hard to port)
4. **No Tests** - No automated test coverage found
5. **Documentation** - Minimal docs, good inline comments in new scripts but not comprehensive
6. **Cleanup Strategy** - No clear plan for removing old .sh files once migration complete

### Why This Structure Makes Sense

- **Backward Compatibility** - Users can still run old scripts while new ones are tested
- **Continuous Improvement** - Each migrated script is better than its predecessor
- **Platform Support** - nixit.sh enables Linux support without maintaining separate codebases
- **Flexible Installation** - Can call either .sh or .zsh version (though currently inconsistent)

---

## What Would It Take to Complete Migration?

### Phase 1: Foundation (1-2 days)
1. Port nixit.sh to Zsh (most complex)
2. Create install-macos.zsh orchestrator
3. Create install-linux.zsh wrapper

### Phase 2: Quick Wins (1 day)
1. Port repos.sh, android.sh, python.sh (simple, <30 lines each)

### Phase 3: Core Scripts (1-2 days)
1. Port private.sh, ssh.sh, dock.sh

### Phase 4: Optional Scripts (1 day)
1. Port mvim.sh, rider.sh, gcc.sh

### Phase 5: Cleanup & Testing (1-2 days)
1. Test all .zsh versions end-to-end
2. Archive old .sh files
3. Update README & documentation

**Estimated Total Effort:** 5-7 days of work

---

## Files to Review First (If Continuing Migration)

1. **`/Users/aaron/Sync/dev/projects/dotfiles/nixit.sh`** - The most complex (95 lines)
2. **`/Users/aaron/Sync/dev/projects/dotfiles/install-macos.sh`** - The orchestrator
3. **`/Users/aaron/Sync/dev/projects/dotfiles/shell.zsh`** - Good reference (well-written Zsh)
4. **`/Users/aaron/Sync/dev/projects/dotfiles/gpg.zsh`** - Sophisticated example

---

## Summary

**This is a well-organized, mid-migration dotfiles repository** showing systematic improvement from Bash to Zsh. The infrastructure is good, the migration approach is sound, but the orchestrator and preprocessor still need updates. The result will be a cleaner, more maintainable, all-Zsh system.

Generated: 2026-01-20
Analysis Location: `/Users/aaron/Sync/dev/projects/dotfiles/`
