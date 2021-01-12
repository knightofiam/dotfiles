#!/usr/bin/env bash

printf "\nConfiguring MacOS system preferences...\n\n"
./macos
printf "\nFinished configuring MacOS system preferences.\n\n"

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

# Configure Xcode
if [[ ! -d "$('xcode-select' -print-path 2>/dev/null)" ]]; then
  sudo xcode-select -switch /Library/Developer/CommandLineTools
fi

printf "Symlinking dotfiles to ${HOME}...\n\n"
THIS_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
dotfiles=("bash_profile" "cvimrc" "duti" "git/gitconfig" "git/gitignore_global" "ideavimrc" "macos" "vim" "vim/vimrc")
cd ${HOME}
# ~/.vim directory gets auto-created by vimrc
# Back it up if it's not a symlink.
if [[ -d .vim && ! -L .vim ]]; then
  printf "${HOME}/.vim already exists, backing up before overwriting...\n"
  # Using gmv from coreutils for backup feature.
  # Must come after `brew bundle` (installs coreutils).
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

# Use Homebrew version of Bash shell.
if [[ $(grep -L "/usr/local/bin/bash" /etc/shells) ]]; then
  echo /usr/local/bin/bash | sudo tee -a /etc/shells
  chsh -s /usr/local/bin/bash
fi

# Configure file associations.
duti duti

# Configure dock icons.
./dock.sh

# Configure gpg.
./gpg.sh

# Use TouchID in terminal.
if [[ $(grep -L "auth       sufficient     pam_tid.so" /etc/pam.d/sudo) ]]; then
  sudo sed -i.bak '2i\
  auth       sufficient     pam_tid.so\
  ' /etc/pam.d/sudo
fi
