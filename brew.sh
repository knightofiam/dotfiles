#!/usr/bin/env bash

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
