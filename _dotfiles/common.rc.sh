#!/usr/bin/env bash

rcfile() {
  echo -e ".$(basename $(echo -e $SHELL))rc"
}
refresh() {
  source $HOME/$(rcfile)
}
add_bin_to_path() {
  for p in "$@"; do
    test -d $p && echo $PATH | grep -q "$p" || export PATH=$PATH:$p
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

dev() {
  local cur_env=$(cat $ENV_FILE)
  local project=$1
  local p=$DEV_DIR/$cur_env/$project
  local pretty_path=${p:$((${#DEV_DIR}+1))}
  if [ ! -d $p ]; then
    echo $pretty_path does not exist > /dev/stderr
    return 1
  fi
  cd $p
  if [ -z $project ] ; then
    ls
    return
  fi
  echo $pretty_path >> $DEV_HIST
  if [ -z $VIMRUNTIME ]; then
    vim .
  fi
}

export EDITOR=nvim
export ENV_FILE=$HOME/.config/CUR_ENV
export DEV_DIR=$HOME/dev
export DEV_HIST=$HOME/.devhist
export USR_DIR=$HOME/usr

if [ -d $USR_DIR/balena-cli ]; then
  if ! which balena &>/dev/null; then
    export PATH=$PATH:$USR_DIR/balena-cli
  fi
fi

HISTSIZE=1000
HISTFILESIZE=2000

# text
alias lower="tr '[:upper:]' '[:lower:]'"
alias upper="tr '[:lower:]' '[:upper:]'"