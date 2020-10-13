#!/usr/bin/env bash

THIS_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
dotfiles=("bash_profile" "cvimrc" "git/gitconfig" "git/gitignore_global" "vim" "vim/vimrc")

cd ${HOME}

printf "\nSymlinking dotfiles to ${HOME}...\n\n"
for dotfilePath in "${dotfiles[@]}"
do
  dotfileName=$(basename "${dotfilePath%.*}")
  printf "Symlinking ${THIS_DIR}/${dotfilePath} as ${HOME}/.${dotfileName}\n"
  ln -sfh ${THIS_DIR}/${dotfilePath} ".${dotfileName}"
done
printf "\nFinished symlinking dotfiles.\n\n"

cd ${THIS_DIR}

printf "Checking if Homebrew is installed...\n\n"
if test ! $(which brew); then
  printf "Installing Homebrew...\n\n"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  printf "\nFinished installing Homebrew.\n\n"
else
  printf "Homebrew is already installed.\n\n"
fi

printf "Updating Homebrew...\n\n"
brew update
printf "Finished updating Homebrew.\n\n"

printf "Installing Homebrew formulae using Brewfile...\n\n"
brew tap homebrew/bundle
brew bundle
printf "\nFinished installing Homebrew formulae using Brewfile.\n\n"
