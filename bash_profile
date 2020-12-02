# Homebrew
export PATH="/usr/local/bin:${PATH}"
export PATH="/usr/local/sbin:${PATH}"

# Ruby
export PATH="/usr/local/opt/ruby/bin:${PATH}"
export PATH="/usr/local/lib/ruby/gems/2.7.0/bin:${PATH}"

# Butler
export PATH="$PATH:$HOME/Library/Application Support/itch/broth/butler/versions/15.20.0"

# Git
alias ga="git add"
alias gaa="git add --all"
alias gaacv="git commit --all --verbose"
alias gap="git add --patch"
alias gcav="git commit --amend --verbose"
alias gcv="git commit --verbose"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log"
alias gp="git push"
alias gpf="git push --force"
alias grp="git reset --patch"
alias gs="git status"

# Bash completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

# Git completion
if [ -f $(brew --prefix)/etc/bash_completion.d/git-completion.bash ]; then
  . $(brew --prefix)/etc/bash_completion.d/git-completion.bash
fi

# Other aliases
alias sbf="source ~/.bash_profile"
