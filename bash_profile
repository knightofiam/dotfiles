# Homebrew
brew_prefix="/usr/local"
[[ -f ${brew_prefix}/bin/brew ]] && export PATH="${brew_prefix}/bin:${brew_prefix}/sbin:${PATH}"

# Butler
butler_path="$HOME/Library/Application Support/itch/broth/butler/versions/15.20.0"
[[ -d ${butler_path} ]] && export PATH="$PATH:${butler_path}"

# Bash completion 2
# https://superuser.com/a/1393343/1229669
bash_completion="${brew_prefix}/etc/profile.d/bash_completion.sh"
[[ -r ${bash_completion} ]] && . ${bash_completion}

# Git completion
git_completion="${brew_prefix}/etc/bash_completion.d/git-completion.bash"
[[ -f ${git_completion} ]] && . ${git_completion}

# iTerm2 command history & many other featuers
# https://iterm2.com/documentation-shell-integration.html
[[ -e ~/.iterm2_shell_integration.bash ]] && . ~/.iterm2_shell_integration.bash

# Python / pyenv / virtualenv
# https://alysivji.github.io/setting-up-pyenv-virtualenvwrapper.html
# https://github.com/pyenv/pyenv/issues/784#issuecomment-826444110
# https://github.com/davidparsson/zsh-pyenv-lazy/blob/master/pyenv-lazy.plugin.zsh
export PYENV_ROOT="${PYENV_ROOT:=${HOME}/.pyenv}"
if ! type pyenv > /dev/null && [ -f "${PYENV_ROOT}/bin/pyenv" ]; then
    export PATH="${PYENV_ROOT}/bin:${PATH}"
fi
if type pyenv > /dev/null; then
  export PATH="${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:${PATH}"
  function pyenv() {
    unset -f pyenv
    eval "$(command pyenv init -)"
    pyenv $@
  }
fi

# Vim
export EDITOR=vim

# AWS Elastic Beanstalk CLI
export PATH="$HOME/.ebcli-virtual-env/executables:$PATH"

# Android
export ANT_HOME=${brew_prefix}/opt/ant
export MAVEN_HOME=${brew_prefix}/opt/maven
export GRADLE_HOME=${brew_prefix}/opt/gradle
export ANDROID_HOME=${brew_prefix}/share/android-sdk
export ANDROID_NDK_HOME=${brew_prefix}/share/android-ndk
export ANDROID_AVD_HOME=$HOME/.android/avd
export ANDROID_SDK_HOME=$ANDROID_HOME
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH=$ANT_HOME/bin:$PATH
export PATH=$MAVEN_HOME/bin:$PATH
export PATH=$GRADLE_HOME/bin:$PATH
export PATH=$ANDROID_HOME/tools:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$ANDROID_HOME/build-tools/33.0.0:$PATH

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

# Mono - Disable crash files
export MONO_CRASH_NOFILE=""

# 1Password SSH Agent
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
