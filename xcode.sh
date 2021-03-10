#!/usr/bin/env bash

# Configure Xcode CLT.
if [[ ! -d "$('xcode-select' -print-path 2>/dev/null)" ]]; then
  printf "Configuring Xcode CLT...\n\n"
  sudo xcode-select --install
  sudo xcode-select -switch /Library/Developer/CommandLineTools
  printf "\nFinished configuring Xcode CLT.\n\n"
fi
