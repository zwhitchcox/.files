#!/usr/bin/env bash
cd $HOME

err_exit() {
  echo "$@" 1>&2
  exit 1
}
if [ -z "$GH_TOKEN" ]; then
  err_exit Need GH_TOKEN
fi

exists() {
  command -v $1 &>/dev/null
  return $?
}

install() {
  if exists pacman; then
    sudo pacman -S --noconfirm $@
  elif exists apt; then
    sudo apt install -y $@
  else
    echo could not find installer 1>&2
    exit 1
  fi
}

update_sources() {
  if exists pacman; then
    pacman -Syyu --noconfirm
  elif exists apt; then
    apt update -y
  else
    echo could not find installer 1>&2
    exit 1
  fi
}

update_sources
