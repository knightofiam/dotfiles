#!/usr/bin/env bash

printf "Configuring MacOS system preferences...\n\n"
./macos
printf "Finished configuring MacOS system preferences.\n\n"

printf "Checking if Homebrew is installed...\n\n"
if test ! $(which brew); then
  printf "Installing Homebrew...\n\n"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  printf "\nFinished installing Homebrew.\n\n"
else
  printf "Homebrew is already installed.\n\n"
fi

printf "Installing Homebrew formulae using Brewfile...\n\n"
brew tap homebrew/bundle
brew bundle
printf "\nFinished installing Homebrew formulae using Brewfile.\n\n"


printf "Symlinking MacVim.app to /Applications...\n\n"
ln -sfh /usr/local/Cellar/macvim/8.2-166_1/MacVim.app /Applications/
printf "Finished symlinking MacVim.app to /Applications.\n\n"

printf "Symlinking dotfiles to ${HOME}...\n\n"
THIS_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
dotfiles=("bash_profile" "cvimrc" "git/gitconfig" "git/gitignore_global" "ideavimrc" "macos" "vim" "vim/vimrc")
cd ${HOME}
for dotfilePath in "${dotfiles[@]}"
do
  dotfileName=$(basename "${dotfilePath}")
  printf "Symlinking ${THIS_DIR}/${dotfilePath} as ${HOME}/.${dotfileName}\n"
  ln -sfh ${THIS_DIR}/${dotfilePath} ".${dotfileName}"
done
printf "\nFinished symlinking dotfiles.\n\n"

