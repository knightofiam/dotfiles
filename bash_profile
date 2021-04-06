# Homebrew
[[ $(which brew) ]] &&\
  export PATH="$(brew --prefix)/bin:$(brew --prefix)/sbin:${PATH}"

# Butler
[[ $(which butler) ]] &&\
  export PATH="$PATH:$HOME/Library/Application Support/itch/broth/butler/versions/15.20.0"

# Bash completion
[[ $(which brew) && -f $(brew --prefix)/etc/bash_completion ]] &&\
  . $(brew --prefix)/etc/bash_completion

# Git completion
[[ $(which brew) && -f $(brew --prefix)/etc/bash_completion.d/git-completion.bash ]] &&\
  . $(brew --prefix)/etc/bash_completion.d/git-completion.bash

# iTerm2 command history & many other featuers
# https://iterm2.com/documentation-shell-integration.html
[[ -e ~/.iterm2_shell_integration.bash ]] && . ~/.iterm2_shell_integration.bash

# Python
[[ $(which pyenv) ]] && eval "$(pyenv init -)"

# Disable CTRL+D 10 times before quitting.
# Prevents accidentally closing the terminal.
set -o ignoreeof

# Pandora
[[ -f ~/.pandora ]] && . ~/.pandora

# Aliases
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

# Private environment variables.
# Use set -a to export all variables without explicitly using 'export'.
[[ -f ~/.extra ]] && { set -a; . ~/.extra; set +a; }
