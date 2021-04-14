#!/usr/bin/env bash

# Use Homebrew version of Bash shell.
if [[ $(grep -L $(brew --prefix)/bin/bash /etc/shells) ]]; then
  echo $(brew --prefix)/bin/bash | sudo tee -a /etc/shells
  chsh -s $(brew --prefix)/bin/bash
fi

# Use Touch ID in shell.
# Uses gsed, homebrew must have installed gnu-sed before this point.
if [[ $(grep -L "auth       sufficient     pam_tid.so" /etc/pam.d/sudo) ]]; then
  sudo gsed -i.bak '2i auth       sufficient     pam_tid.so' /etc/pam.d/sudo
fi
