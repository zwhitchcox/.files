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


source_env \
  $HOME/.cargo/env \
  /usr/share/nvm/init-nvm.sh

export EDITOR=nvim
export DEV_DIR=$HOME/dev
export USR_DIR=$HOME/usr
if [ -n "$hist_file" ]; then
  export HISTFILE="$hist_file"
fi
export HISTSIZE=100000
export HISTFILESIZE=200000
export HISTCONTROL=ignoreboth:erasedups
export EDITOR=nvim
export DEV_HIST="$HOME/.devhist"
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

add_bin_to_path "$HOME/dev/$USER/bin/"{unix,linux,git,project_management,sessions,desktop}
add_bin_to_path $HOME/dev/$USER/devops/scripts
if [ "$status_shown" != true ] && [ -n "$VIMRUNTIME" ] && [ -n "$TMUX" ] ; then
  status
  export status_shown=true
fi
