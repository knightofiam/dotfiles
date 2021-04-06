#!/usr/bin/env bash

# Using gmv from coreutils for backup feature.
# Must come after brew.sh (installs coreutils).
MV_COMMAND="$(brew --prefix)/bin/gmv"
THIS_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

printf "Symlinking dotfiles to ${HOME}...\n\n"

readarray -s 2 -t DOTFILES < "${THIS_DIR}/symlinks"

for dotfilepath in "${DOTFILES[@]}"
do
  dotfilename=$(basename "${dotfilepath}")
  src="${THIS_DIR}/${dotfilepath}"
  dst="${HOME}/.${dotfilename}"

  if [[ ! -f ${src} && ! -d ${src} ]]; then
    printf "WARNING: ${src} doesn't exist, skipping...\n"
    continue
  fi

  # Back up existing dotfiles before replacing if they're not symlinks.
  if [[ ( -f ${dst} || -d ${dst} ) && ! -L ${dst} ]]; then
    printf "${dst} already exists, backing up before overwriting...\n"
    if command -v ${MV_COMMAND} &>/dev/null; then
      ${MV_COMMAND} --backup=numbered "${dst}" "${dst}.backup"
    else
      printf "WARNING: Can't find ${MV_COMMAND} for making backups. Skipping ${dst}...\n"
      continue
    fi
    printf "Finished backing up ${dst}.\n"
  fi

  printf "Symlinking ${src} as ${dst}\n"
  ln -sfn ${src} "${dst}"
done

printf "\nFinished symlinking dotfiles.\n\n"
