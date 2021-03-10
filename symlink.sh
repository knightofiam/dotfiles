#!/usr/bin/env bash

printf "Symlinking dotfiles to ${HOME}...\n\n"

THIS_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
dotfiles=("bash_profile" "cvimrc" "duti" "git/gitconfig" "git/gitignore_global" "ideavimrc" "vim" "vim/vimrc")

cd ${HOME}

# ~/.vim directory gets auto-created by vimrc
# Back it up if it's not a symlink.
if [[ -d .vim && ! -L .vim ]]; then
  printf "${HOME}/.vim already exists, backing up before overwriting...\n"
  # Using gmv from coreutils for backup feature.
  # Must come after brew.sh (installs coreutils).
  /usr/local/bin/gmv --backup=numbered ".vim" ".vim.backup"
  printf "\nFinished backing up ${HOME}/.vim."
fi

for dotfilePath in "${dotfiles[@]}"
do
  dotfileName=$(basename "${dotfilePath}")
  printf "Symlinking ${THIS_DIR}/${dotfilePath} as ${HOME}/.${dotfileName}\n"
  ln -sfh ${THIS_DIR}/${dotfilePath} ".${dotfileName}"
done

printf "\nFinished symlinking dotfiles.\n\n"