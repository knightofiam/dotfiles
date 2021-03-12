#!/usr/bin/env bash

# Use Homebrew version of Bash shell.
if [[ $(grep -L "/usr/local/bin/bash" /etc/shells) ]]; then
  echo /usr/local/bin/bash | sudo tee -a /etc/shells
  chsh -s /usr/local/bin/bash
fi

# Use Touch ID in shell.
# Uses gsed, homebrew must have installed gnu-sed before this point.
if [[ $(grep -L "auth       sufficient     pam_tid.so" /etc/pam.d/sudo) ]]; then
  sudo gsed -i.bak '2i auth       sufficient     pam_tid.so' /etc/pam.d/sudo
fi
