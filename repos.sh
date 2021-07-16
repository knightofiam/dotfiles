#!/usr/bin/env bash

# Configure dotfiles git repository.
# Preserve any local changes.

THIS_DIR="${BASH_SOURCE%/*}"
[[ ! -d "$THIS_DIR" ]] && THIS_DIR="$PWD"

cd ${THIS_DIR}

if [[ ! $(git rev-parse --is-inside-work-tree 2>/dev/null) ]]; then
  git init
  git config remote.origin.url >/dev/null 2>&1 || \
    git remote add origin https://github.com/knightofiam/dotfiles.git
  git fetch
  git reset origin/master
  git branch --set-upstream-to=origin/master
  git ls-files -z --deleted | xargs -0 git checkout --
  git submodule update --init --recursive
fi

# Configure GitHub development projects, including dotfiles.
mkdir -p "${HOME}/Sync/dev/projects/godot"
mv "${HOME}/dotfiles" "${HOME}/Sync/dev/projects/"
git clone https://github.com/forerunnergames/coa.git "${HOME}/Sync/dev/projects/godot/coa"
