#!/usr/bin/env bash

rcfile() {
  echo -e ".$(basename $(echo -e $SHELL))rc"
}
refresh() {
  source $HOME/$(rcfile)
}
add_bin_to_path() {
  for p in "$@"; do
    test -d $p && echo $PATH | grep -q "(^|:)$p(\$|:)" || export PATH=$PATH:$p
  done
}

source_env() {
  for p in ${1[@]}; do
    test -f $p && source $p
  done
}

switch_env() {
  set_env $1
  eval `get_env`
  status
}

source_env \
  $HOME/.cargo/env \
  /usr/share/nvm/init-nvm.sh

export EDITOR=nvim
export ENV_FILE=$HOME/.config/CUR_ENV
export DEV_DIR=$HOME/dev
export DEV_HIST=$HOME/.devhist
export USR_DIR=$HOME/usr
if [ -n "$hist_file" ]; then
  export HISTFILE="$hist_file"
fi
export HISTSIZE=100000
export HISTFILESIZE=200000
export HISTCONTROL=ignoreboth:erasedups
export EDITOR=nvim
alias vim=nvim


# # Appends every command to the history file once it is executed
 setopt inc_append_history
# # Reloads the history whenever you use it
 setopt share_history
 setopt HIST_IGNORE_SPACE

if [ -d $USR_DIR/balena-cli ]; then
  if ! which balena &>/dev/null; then
    export PATH=$PATH:$USR_DIR/balena-cli
  fi
fi


# text
alias lower="tr '[:upper:]' '[:lower:]'"
alias upper="tr '[:lower:]' '[:upper:]'"