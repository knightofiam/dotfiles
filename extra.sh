#!/usr/bin/env bash

THIS_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

printf "\nConfiguring ${HOME}/.extra...\n\n"

# Configure ~/.extra for local settings.
if [[ ! -e ${HOME}/.extra && -e ${HOME}/Sync/dev/.extra ]]; then
  printf "Symlinking ${HOME}/Sync/dev/.extra as ${HOME}/.extra\n"
  ln -sfh ${HOME}/Sync/dev/.extra .extra
elif [[ ! -e ${HOME}/.extra && ! -e ${HOME}/Sync/dev/.extra ]]; then
  printf "WARNING: ${HOME}/Sync/dev/.extra doesn't exist\n"
  printf "Copying ${THIS_DIR}/.extra to ${HOME}/extra...\n"
  cp "${THIS_DIR}/extra" "${HOME}/.extra"
else
  printf "WARNING: ${HOME}/.extra exists, skipping...\n"
fi

printf "\nFinished configuring ${HOME}/.extra.\n\n"
