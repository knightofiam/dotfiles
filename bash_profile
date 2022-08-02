# Homebrew
brew_prefix="/usr/local"
[[ -f ${brew_prefix}/bin/brew ]] && export PATH="${brew_prefix}/bin:${brew_prefix}/sbin:${PATH}"

# Butler
butler_path="$HOME/Library/Application Support/itch/broth/butler/versions/15.20.0"
[[ -d ${butler_path} ]] && export PATH="$PATH:${butler_path}"

# Bash completion
bash_completion="${brew_prefix}/etc/bash_completion"
[[ -f ${bash_completion} ]] && . ${bash_completion}

# Git completion
git_completion="${brew_prefix}/etc/bash_completion.d/git-completion.bash"
[[ -f ${git_completion} ]] && . ${git_completion}

# iTerm2 command history & many other featuers
# https://iterm2.com/documentation-shell-integration.html
[[ -e ~/.iterm2_shell_integration.bash ]] && . ~/.iterm2_shell_integration.bash

# Python
command -v pyenv &>/dev/null && eval "$(pyenv init -)"
export PATH=/usr/local/share/python:$PATH

# virtualenv
WORKON_HOME=$HOME/.virtualenvs
VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
source /usr/local/bin/virtualenvwrapper.sh

# AWS Elastic Beanstalk CLI
export PATH="$HOME/.ebcli-virtual-env/executables:$PATH"

# Pandora
[[ -f ~/.pandora ]] && . ~/.pandora

# Aliases
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

# Private environment variables.
# Use set -a to export all variables without explicitly using 'export'.
[[ -f ~/.extra ]] && { set -a; . ~/.extra; set +a; }

# Disable CTRL+D 10 times before quitting.
# Prevents accidentally closing the terminal.
set -o ignoreeof
