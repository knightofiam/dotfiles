#!/usr/bin/env bash

THIS_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
POST_INSTALL="${HOME}/Sync/dev/dotfiles/post-install.sh"
EXTRA_TEMPLATE="${THIS_DIR}/extra"
EXTRA_SRC="${HOME}/Sync/dev/dotfiles/.extra"
EXTRA_DST="${HOME}/.extra"

printf "Configuring ${EXTRA_DST} for private settings...\n\n"

# Configure ~/.extra for local settings.
if [[ ! -e ${EXTRA_DST} && -e ${EXTRA_SRC} ]]; then
  printf "Symlinking ${EXTRA_SRC} as ${EXTRA_DST}\n"
  ln -sfh "${EXTRA_SRC}" "${EXTRA_DST}"
elif [[ ! -e ${EXTRA_DST} && ! -e ${EXTRA_SRC} ]]; then
  printf "WARNING: ${EXTRA_SRC} doesn't exist\n"
  printf "Copying ${EXTRA_TEMPLATE} to ${EXTRA_DST}...\n"
  cp "${EXTRA_TEMPLATE}" "${EXTRA_DST}"
else
  printf "WARNING: ${EXTRA_DST} exists, skipping...\n"
fi

printf "\nFinished configuring ${EXTRA_DST}.\n"

# Run private post-install.
printf "\nRunning private post-install using ${POST_INSTALL}...\n\n"

if [[ -f ${POST_INSTALL} ]]; then
  ${POST_INSTALL}
else
  printf "WARNING: ${POST_INSTALL} doesn't exist, skipping...\n"
fi

printf "\nFinished running private post-install using ${POST_INSTALL}.\n\n"
