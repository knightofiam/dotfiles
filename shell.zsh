#!/usr/bin/env zsh
set -euo pipefail

### --- Homebrew zsh bootstrap -------------------------------------------------
# Detect Homebrew prefix on Apple Silicon / Intel
BREW_PREFIX="${BREW_PREFIX:-/opt/homebrew}"
[[ -x /usr/local/bin/brew && ! -x ${BREW_PREFIX}/bin/brew ]] && BREW_PREFIX="/usr/local"

# Ensure Homebrew is in PATH for this session
if [[ -x "${BREW_PREFIX}/bin/brew" ]]; then
  eval "$(${BREW_PREFIX}/bin/brew shellenv)"
fi

# 1) Install Homebrew zsh if missing
if ! command -v zsh >/dev/null || [[ "$(command -v zsh)" != "${BREW_PREFIX}/bin/zsh" ]]; then
  echo "Installing Homebrew zsh..."
  brew install zsh
fi

BREW_ZSH="${BREW_PREFIX}/bin/zsh"

# 2) Make sure /etc/shells includes Homebrew zsh
if ! grep -qxF "${BREW_ZSH}" /etc/shells; then
  echo "Adding ${BREW_ZSH} to /etc/shells (sudo)..."
  echo "${BREW_ZSH}" | sudo tee -a /etc/shells >/dev/null
fi

# 3) Make Homebrew zsh the login shell if not already
if [[ "${SHELL:-}" != "${BREW_ZSH}" ]]; then
  echo "Changing login shell to ${BREW_ZSH}..."
  chsh -s "${BREW_ZSH}"
  echo "Done. Restart your terminal session to use it."
fi

# 4) Ensure Homebrew is initialized on login
ZPROFILE="${HOME}/.zprofile"
LINE='eval "$('"${BREW_PREFIX}"'/bin/brew shellenv)"'
if ! grep -Fq "${LINE}" "${ZPROFILE}" 2>/dev/null; then
  echo "Adding Homebrew shellenv to ${ZPROFILE}..."
  {
    echo ""
    echo "# Initialize Homebrew environment (added by shell.zsh)"
    echo "${LINE}"
  } >> "${ZPROFILE}"
fi

echo "✅ Homebrew zsh set up at: ${BREW_ZSH}"

### --- Touch ID for sudo (macOS) ---------------------------------------------
# Use Touch ID for sudo via PAM, in a macOS-safe/idempotent way.
enable_touchid_sudo() {
  # Touch ID hardware present?
  if ! ioreg -l | grep -q '"BiometricKit"'; then
    echo "ℹ️  No Touch ID hardware detected; skipping Touch ID sudo."
    return 0
  fi

  # pam_tid available?
  if [[ ! -e /usr/lib/pam/pam_tid.so ]]; then
    echo "ℹ️  pam_tid.so not found; skipping Touch ID sudo."
    return 0
  fi

  local pam_file="/etc/pam.d/sudo_local"
  local pam_line='auth       sufficient     pam_tid.so'

  # Create or update sudo_local (preferred over editing /etc/pam.d/sudo)
  if sudo test -f "${pam_file}"; then
    if sudo grep -qxF "${pam_line}" "${pam_file}"; then
      echo "✅ Touch ID already enabled for sudo (sudo_local present)."
    else
      echo "Enabling Touch ID in ${pam_file} (sudo)…"
      # Prepend to ensure it’s evaluated before other auth lines
      sudo /bin/sh -c "printf '%s\n%s\n' '${pam_line}' \"\$(cat '${pam_file}')\" > '${pam_file}.tmp' && mv '${pam_file}.tmp' '${pam_file}'"
      echo "✅ Touch ID enabled for sudo."
    fi
  else
    echo "Creating ${pam_file} with Touch ID rule (sudo)…"
    printf '%s\n' "${pam_line}" | sudo tee "${pam_file}" >/dev/null
    echo "✅ Touch ID enabled for sudo."
  fi

  # Optional: set a friendlier sudo timestamp timeout (e.g., 15 minutes)
  # This goes in /etc/sudoers.d, validated by visudo.
  local sudoers_snip="/etc/sudoers.d/10-touchid-timeout"
  local desired="Defaults timestamp_timeout=15"
  local tmp="$(mktemp)"

  if sudo test -f "${sudoers_snip}" && sudo grep -qxF "${desired}" "${sudoers_snip}"; then
    echo "✅ sudo timestamp timeout already set (15 minutes)."
  else
    echo "Setting sudo timestamp timeout to 15 minutes (sudo)…"
    printf '%s\n' "${desired}" > "${tmp}"
    # Validate before moving into place
    if sudo visudo -c -f "${tmp}" >/dev/null 2>&1; then
      sudo install -m 0440 "${tmp}" "${sudoers_snip}"
      echo "✅ Sudo timeout configured."
    else
      echo "⚠️  Skipping timeout config; visudo validation failed."
    fi
    rm -f "${tmp}"
  fi
}

enable_touchid_sudo || {
  echo "⚠️  Touch ID setup encountered an issue."
}

echo "Done."
