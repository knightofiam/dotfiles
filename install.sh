#!/usr/bin/env bash

THIS_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

cd ${HOME}

printf "\nSymlinking dotfiles to ${HOME}...\n\n"

dotfiles=("bash_profile" "cvimrc" "git/gitconfig" "git/gitignore_global" "vim" "vim/vimrc")

for dotfilePath in "${dotfiles[@]}"
do
  dotfileName=$(basename "${dotfilePath%.*}")
  printf "Symlinking ${THIS_DIR}/${dotfilePath} as ${HOME}/.${dotfileName}\n"
  ln -sfh ${THIS_DIR}/${dotfilePath} ".${dotfileName}"
done

printf "\nFinished symlinking dotfiles.\n\n"

cd ${THIS_DIR}

printf "Checking if Homebrew is installed...\n\n"
which -s brew
if [[ $? != 0 ]] ; then
  printf "Installing Homebrew...\n\n"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  printf "\nFinished installing Homebrew.\n\n"
else
  printf "Homebrew is already installed.\n"
  printf "Updating Homebrew...\n\n"
  brew update
  printf "Finished updating Homebrew\n\n"
fi

printf "Installing Homebrew formulae using Brewfile...\n\n"
brew bundle
printf "\nFinished installing Homebrew formulae using Brewfile.\n\n"
