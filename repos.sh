#!/usr/bin/env bash

# Configure dotfiles git repository.
# Preserve any local changes.
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
mkdir -p "${HOME}/projects/godot"
mv "${HOME}/dotfiles" "${HOME}/projects/"
git clone https://github.com/forerunnergames/coa.git "${HOME}/projects/godot/coa"
