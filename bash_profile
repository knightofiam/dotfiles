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
alias gb="git branch"
alias gc="git checkout"
alias gcav="git commit --amend --verbose"
alias gcv="git commit --verbose"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log"
alias gll=" git log --oneline --no-show-signature --color | nl | less -R"
alias gp="git push"
alias gpf="git push --force"
alias gr="git reset"
alias grp="git reset --patch"
alias gs="git status"
alias gsh="git show"
alias gshn="git show --name-only --oneline"
alias gsl="git stash list"
alias gsp="git stash pop"
alias gss="git stash save"

# Bash completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

# Git completion
if [ -f $(brew --prefix)/etc/bash_completion.d/git-completion.bash ]; then
  . $(brew --prefix)/etc/bash_completion.d/git-completion.bash
fi

# Other aliases
alias coa="cd ~/projects/godot/coa && gs"
alias dotfiles="cd ~/projects/dotfiles && gs"
alias eb="vim ~/.bash_profile"
alias sb="source ~/.bash_profile"
alias ev="vim ~/.vimrc"

# SecureSet
alias ss="cd ~/Sync/secureset && pwd && ls"
alias ssc100="cd ~/Sync/secureset/crypto/100 && pwd && ls"
alias ssc200="cd ~/Sync/secureset/crypto/200 && pwd && ls"
alias ssc300="cd ~/Sync/secureset/crypto/300 && pwd && ls"
alias ssc="cd ~/Sync/secureset/crypto && pwd && ls"
alias ssg100="cd ~/Sync/secureset/grc/100 && pwd && ls"
alias ssg200="cd ~/Sync/secureset/grc/200 && pwd && ls"
alias ssg="cd ~/Sync/secureset/grc && pwd && ls"
alias ssn100="cd ~/Sync/secureset/net/100 && pwd && ls"
alias ssn200="cd ~/Sync/secureset/net/200 && pwd && ls"
alias ssn300="cd ~/Sync/secureset/net/300 && pwd && ls"
alias ssn="cd ~/Sync/secureset/net && pwd && ls"
alias ssp100="cd ~/Sync/secureset/python/100 && pwd && ls"
alias ssp200="cd ~/Sync/secureset/python/200 && pwd && ls"
alias ssp="cd ~/Sync/secureset/python && pwd && ls"
alias sss100="cd ~/Sync/secureset/sys/100 && pwd && ls"
alias sss200="cd ~/Sync/secureset/sys/200 && pwd && ls"
alias sss300="cd ~/Sync/secureset/sys/300 && pwd && ls"
alias sss="cd ~/Sync/secureset/sys && pwd && ls"
alias sst="cd ~/Sync/secureset/threat && pwd && ls"

# Python
eval "$(pyenv init -)"

# iTerm2
if [ -e ~/.iterm2_shell_integration.bash ]; then
  source ~/.iterm2_shell_integration.bash
fi

# Private env vars
set -a
source ~/.extra
set +a
