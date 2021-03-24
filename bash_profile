# Homebrew
export PATH="/usr/local/bin:${PATH}"
export PATH="/usr/local/sbin:${PATH}"

# Ruby
export PATH="/usr/local/opt/ruby/bin:${PATH}"
export PATH="/usr/local/lib/ruby/gems/2.7.0/bin:${PATH}"

# Butler
export PATH="$PATH:$HOME/Library/Application Support/itch/broth/butler/versions/15.20.0"

# Bash completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

# Git completion
if [ -f $(brew --prefix)/etc/bash_completion.d/git-completion.bash ]; then
  . $(brew --prefix)/etc/bash_completion.d/git-completion.bash
fi

# iTerm2 command history & many other featuers
# https://iterm2.com/documentation-shell-integration.html
if [ -e ~/.iterm2_shell_integration.bash ]; then
  source ~/.iterm2_shell_integration.bash
fi

# Python
eval "$(pyenv init -)"

# Disable CTRL+D 10 times before quitting.
# Prevents accidentally closing the terminal.
set -o ignoreeof

# Pandora
source ~/.pandora

# Aliases
source ~/.bash_aliases

# Private environment variables.
# Use set -a to export all variables without explicitly using 'export'.
set -a
source ~/.extra
set +a
