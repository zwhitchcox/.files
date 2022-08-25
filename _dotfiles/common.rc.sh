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

starts_with() {
  [[ $1 == $2* ]] && return 0
  return 1
}

dev() {
  if [ -z "$1" ]; then
    echo "Select a project"
    dev $(get_selection ""$(list_projects))
    return 0
  fi

  local cur_env=$(cat $ENV_FILE)
  local paths=("${DEV_DIR}" "${DEV_DIR}/${cur_env}"  ".")
  local project=""
  for p in ${paths[@]} ; do
    if [ -d "${p}/${1}/.git" ]; then
      project="$p/$1"
      break
    fi
  done

  if [ -z "$project" ]; then
    echo "Couldn't find project $1" 1>&2
    return 1
  fi

  if starts_with "$project" "$DEV_DIR"; then
    echo ${project:$((${#DEV_DIR}+1))} >> $DEV_HIST
  fi

  cd "$project"

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
