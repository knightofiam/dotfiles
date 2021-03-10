#!/usr/bin/env bash

# Sign into 1Password
eval $(op signin my.1password.com ${EMAIL})

# Backup & rename any existing private key file with the same name because
# op refuses to overwrite.
if [[ -f ${HOME}/key.asc ]]; then
  printf "\n${HOME}/key.asc already exists, backing up before overwriting...\n"
  # Using gmv from coreutils for backup feature.
  # Must come after `brew bundle` (installs coreutils).
  /usr/local/bin/gmv --backup=numbered "${HOME}/key.asc" "${HOME}/key.asc.backup"
  printf "\nFinished backing up ${HOME}/key.asc.\n\n"
fi

# Import my personal private key from 1Password documents as ~/key.asc into gpg.
# (op locks down file permissions by default to 0600)
printf "\nImporting & signing your personal private key from 1Password documents...\n"
op get document "My Private Key.asc" --vault Private --output ${HOME}/key.asc
gpg --import "${HOME}/key.asc"
gpg --sign-key ${EMAIL}
printf "\nDeleting temporary file ${HOME}/key.asc...\n"
rm "${HOME}/key.asc"
printf "\nDone.\n"
printf "\nFinished importing your personal private key from 1Password documents.\n\n"

# Import & sign GitHub's web-based key for signed pull-request merges.
printf "\nImporting & signing GitHub's web-based key for signed pull-request merges...\n\n"
curl https://github.com/web-flow.gpg | gpg --import
gpg --sign-key noreply@github.com
printf "\nFinished importing & signing GitHub's web-based key for signed pull-request merges.\n\n"
