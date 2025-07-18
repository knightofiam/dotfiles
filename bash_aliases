#!/usr/bin/env bash

# Git
alias ga="git add"
alias gaa="git add --all"
alias gaaacne="git commit --all --amend --no-edit"
alias gaaacv="git commit --all --amend --verbose"
alias gaacv="git commit --all --verbose"
alias gap="git add --patch"
alias gb="git branch"
alias gc="git checkout"
alias gcav="git commit --amend --verbose"
alias gcv="git commit --verbose"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log"
alias gll="git log --oneline --no-show-signature --color | nl | less -R"
alias glll="git log --stat --oneline --no-show-signature --color | grep --line-buffered -vE 'files? changed,' | nl | less -R"
alias gpl="git pull"
alias gpp="git push"
alias gppf="git push --force"
alias gprc="gh pr create"
alias gprcf="gh pr create --fill"
alias gprcf2="git_pr_create_from_remote_branch"
alias gpsu="git push --set-upstream origin HEAD"
alias gprm="gh pr merge"
alias gprms="gh pr merge --squash"
alias gprmsd="gh pr merge --squash --delete-branch"
alias gprmsda="gh pr merge --squash --delete-branch --auto"
alias gr="git reset"
alias grp="git reset --patch"
alias gs="git status"
alias gsh="git show"
alias gshn="git show --name-only --oneline --no-show-signature"
alias gsl="git stash list"
alias gsp="git stash pop"
alias gss="git stash save"
alias gfpr="git_fetch_pr"
alias gupr="git_pull_pr"
alias gcpr="git_checkout_pr"
alias gdpr="git_delete_pr"
alias gum="git checkout main && git fetch upstream && git rebase upstream/main && git push origin main"

# Miscellaneous
alias coa="cd ~/Sync/dev/projects/godot/coa && gs"
alias dotfiles="cd ~/Sync/dev/projects/dotfiles && gs"
alias ea="vim ~/.bash_aliases"
alias ebp="vim ~/.bash_profile"
alias es="vim ~/.vim/spell/en.utf-8.add"
alias ev="vim ~/.vimrc"
alias godot="/Applications/Godot_mono.app/Contents/MacOS/Godot"
alias godot2="cd ~/Sync/dev/projects/godot && ls"
alias unity="cd ~/Sync/dev/projects/unity && ls"
alias ip="curl ifconfig.me"
alias py="cd ~/Sync/dev/projects/python && ls"
alias sbp="source ~/.bash_profile"
alias website="cd ~/Sync/dev/projects/website && gs"

# Function to fetch a PR and create a local branch with the PR title
git_fetch_pr() {
  if [ -z "$1" ]; then
    echo "Usage: gfpr <pr-number>"
    return 1
  fi

  pr_number=$1
  # Retrieve and format the PR title
  pr_title=$(gh pr view $pr_number --json title -q .title 2>/dev/null | tr '[:upper:]' '[:lower:]' | sed -E 's/[[:space:]]+/-/g; s/[^a-z0-9-]//g; s/-+$//')

  if [ -z "$pr_title" ]; then
    echo "Failed to fetch PR title for PR #$pr_number"
    return 1
  fi

  local_branch_name="pr-$pr_number-$pr_title"

  if git show-ref --verify --quiet refs/heads/$local_branch_name; then
    echo "Branch '$local_branch_name' already exists."
    return 1
  fi

  git fetch upstream pull/$pr_number/head:$local_branch_name && git checkout $local_branch_name
}

# Function to pull changes to an existing PR branch
git_pull_pr() {
  if [ -z "$1" ]; then
    echo "Usage: gupr <pr-number>"
    return 1
  fi

  pr_number=$1
  # Retrieve and format the PR title
  pr_title=$(gh pr view $pr_number --json title -q .title 2>/dev/null | tr '[:upper:]' '[:lower:]' | sed -E 's/[[:space:]]+/-/g; s/[^a-z0-9-]//g; s/-+$//')
  local_branch_name="pr-$pr_number-$pr_title"

  if ! git show-ref --verify --quiet refs/heads/$local_branch_name; then
    echo "Branch '$local_branch_name' does not exist. Use gfpr to fetch the PR first."
    return 1
  fi

  git checkout $local_branch_name && git reset --hard HEAD^ && git pull upstream pull/$pr_number/head
}

# Function to check out an existing PR branch
git_checkout_pr() {
  if [ -z "$1" ]; then
    echo "Usage: gcpr <pr-number>"
    return 1
  fi

  pr_number=$1
  # Retrieve and format the PR title
  pr_title=$(gh pr view $pr_number --json title -q .title 2>/dev/null | tr '[:upper:]' '[:lower:]' | sed -E 's/[[:space:]]+/-/g; s/[^a-z0-9-]//g; s/-+$//')
  local_branch_name="pr-$pr_number-$pr_title"

  if ! git show-ref --verify --quiet refs/heads/$local_branch_name; then
    echo "Branch '$local_branch_name' does not exist. Use gfpr to fetch the PR first."
    return 1
  fi

  git checkout $local_branch_name
}

# Function to delete a PR branch
git_delete_pr() {
  if [ -z "$1" ]; then
    echo "Usage: gdpr <pr-number>"
    return 1
  fi

  pr_number=$1
  # Retrieve and format the PR title
  pr_title=$(gh pr view $pr_number --json title -q .title 2>/dev/null | tr '[:upper:]' '[:lower:]' | sed -E 's/[[:space:]]+/-/g; s/[^a-z0-9-]//g; s/-+$//')
  local_branch_name="pr-$pr_number-$pr_title"

  if ! git show-ref --verify --quiet refs/heads/$local_branch_name; then
    echo "Branch '$local_branch_name' does not exist."
    return 1
  fi

  git branch -D $local_branch_name
}

# Function to create a PR directly from someone else's fork branch to upstream
git_pr_create_from_remote_branch() {
  if [ $# -ne 1 ]; then
    echo "Usage: gprcf2 remote/branch"
    return 1
  fi

  # Split the input into remote and branch
  IFS='/' read -r fork_name fork_branch <<< "$1"

  # Validate input
  if [ -z "$fork_name" ] || [ -z "$fork_branch" ]; then
    echo "Invalid input. Use format: remote/branch-name"
    return 1
  fi

  # Check if the remote exists
  if ! git remote get-url "$fork_name" >/dev/null 2>&1; then
    echo "Remote '$fork_name' does not exist. Add it first with:"
    echo "git remote add $fork_name <repository-url>"
    return 1
  fi

  # Get the fork's owner from the remote URL
  fork_owner=$(git remote get-url "$fork_name" | sed -n 's/.*github.com[:\/]\([^\/]*\)\/.*/\1/p')

  echo "Creating PR from $fork_owner:$fork_branch..."

  # Fetch the remote branch
  git fetch "$fork_name" "$fork_branch"
  
  # Save current branch
  current_branch=$(git symbolic-ref --short HEAD)
  
  # Create temp branch name
  temp_branch="temp-pr-${fork_name}-${fork_branch}"
  
  # Check if temp branch exists and delete if it does
  if git show-ref --verify --quiet refs/heads/"$temp_branch"; then
    git branch -D "$temp_branch"
  fi
  
  # Create a temporary local branch from the remote branch
  git checkout -b "$temp_branch" "$fork_name/$fork_branch"
  
  # Create the PR
  gh pr create --fill
  
  # Return to original branch
  git checkout "$current_branch"
  
  # Clean up temp branch
  git branch -D "$temp_branch"
}
