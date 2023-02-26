#!/usr/bin/env bash

export EDITOR=nvim
export HISTSIZE=100000
export HISTFILESIZE=200000
export HISTCONTROL=ignoreboth:erasedups
export RC_FILE=".$(basename "$SHELL")rc"
alias vim=nvim

reload_rc() {
  source "$HOME/$(rcfile)"
}

source_env() {
  test -f "$1" && source "$1"
}

source_env "$HOME/.cargo/env"
source_env "/usr/share/nvm/init-nvm.sh"


# Enable history settings if shell supports it
if [[ -n "$(which setopt)" ]]; then
  setopt inc_append_history
  setopt share_history
  setopt hist_ignore_space
fi
#
# Text processing aliases
alias lower="tr '[:upper:]' '[:lower:]'"
alias upper="tr '[:lower:]' '[:upper:]'"
