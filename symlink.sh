#!/usr/bin/env bash

printf "Symlinking dotfiles to ${HOME}...\n\n"

THIS_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
dotfiles=("bash_profile" "cvimrc" "duti" "git/gitconfig" "git/gitignore_global" "ideavimrc" "ssh" "vim" "vim/vimrc")

for dotfilePath in "${dotfiles[@]}"
do
  dotfileName=$(basename "${dotfilePath}")

  if [[ ! -f ${THIS_DIR}/${dotfilePath} && ! -d ${THIS_DIR}/${dotfilePath} ]]; then
    printf "WARNING: ${THIS_DIR}/${dotfilePath} doesn't exist, skipping...\n"
    continue
  fi

  # Back up existing dotfiles before replacing if they're not symlinks.
  if [[ ( -f ${HOME}/.${dotfileName} || -d ${HOME}/.${dotfileName} ) && ! -L ${HOME}/.${dotfileName} ]]; then
    printf "${HOME}/.${dotfileName} already exists, backing up before overwriting...\n"
    # Using gmv from coreutils for backup feature.
    # Must come after brew.sh (installs coreutils).
    /usr/local/bin/gmv --backup=numbered "${HOME}/.${dotfileName}" "${HOME}/.${dotfileName}.backup"
    printf "Finished backing up ${HOME}/.${dotfileName}.\n"
  fi

  printf "Symlinking ${THIS_DIR}/${dotfilePath} as ${HOME}/.${dotfileName}\n"
  ln -sfn ${THIS_DIR}/${dotfilePath} "${HOME}/.${dotfileName}"
done

printf "\nFinished symlinking dotfiles.\n\n"
