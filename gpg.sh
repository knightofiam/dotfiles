#!/usr/bin/env bash

# Using gmv from coreutils for backup feature.
# Must come after brew.sh (installs coreutils).
MV_COMMAND="$(brew --prefix)/bin/gmv"

# Sign into 1Password
if [[ ! -z ${ONE_PASSWORD_EMAIL} && ${ONE_PASSWORD_EMAIL} != "first.last@example.com" ]]; then
  eval $(op signin my.1password.com ${ONE_PASSWORD_EMAIL})
else
  printf "\nYour email address isn't set up.\n"
  read -p "Enter your my.1password.com account email: " one_password_email
  eval $(op signin my.1password.com ${one_password_email})
fi

# Backup & rename any existing private key file with the same name because
# op refuses to overwrite.
if [[ -f ${HOME}/key.asc ]]; then
  printf "\n${HOME}/key.asc already exists, backing up before overwriting...\n"
  ${MV_COMMAND} --backup=numbered "${HOME}/key.asc" "${HOME}/key.asc.backup"
  printf "\nFinished backing up ${HOME}/key.asc.\n\n"
fi

# Import my personal private key from 1Password documents as ~/key.asc into gpg.
# (op locks down file permissions by default to 0600)
printf "\nImporting & signing your personal private key from 1Password documents...\n\n"
op get document "My Private Key.asc" --vault Private --output ${HOME}/key.asc
gpg --import "${HOME}/key.asc"
if [[ ! -z ${GPG_KEY_SIGNING_EMAIL} && ${GPG_KEY_SIGNING_EMAIL} != "first.last@example.com" ]]; then
  gpg --sign-key ${GPG_KEY_SIGNING_EMAIL}
else
  printf "\nYour email address isn't set up.\n"
  read -p "Enter your personal GPG key-signing email: " gpg_key_signing_email
  gpg --sign-key ${gpg_key_signing_email}
fi
printf "\nDeleting temporary file ${HOME}/key.asc...\n"
rm "${HOME}/key.asc"
printf "\nDone.\n"
printf "\nFinished importing your personal private key from 1Password documents.\n\n"

# Import & sign GitHub's web-based key for signed pull-request merges.
printf "Importing & signing GitHub's web-based key for signed pull-request merges...\n\n"
curl https://github.com/web-flow.gpg | gpg --import
gpg --sign-key noreply@github.com
printf "\nFinished importing & signing GitHub's web-based key for signed pull-request merges.\n\n"
