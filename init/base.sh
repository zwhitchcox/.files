#!/usr/bin/env bash
sudo echo -n '' # acquire sudo permissions early
set -x

debug() {
  [ "$DEBUG" == true ] && echo "$@"
}

export PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
is_linux() {
  [ "$PLATFORM" == linux ]
}

is_darwin() {
  [ "$PLATFORM" == darwin ]
}

is_balena() {
  [ "$IN_BALENA" == true ]
}

exists() {
  command -v $1 &>/dev/null
  return $?
}

install_nvm() {
  local release
  release=$(latest_release nvm-sh/nvm) || return 1
  curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/${release}/install.sh | bash || return 1
}

install_balena() {
  local release
  release=$(latest_release balena-io/balena-cli)
  local dlpath=/tmp/balena-cli.zip
  curl -sL -o $dlpath "https://github.com/balena-io/balena-cli/releases/download/${release}/balena-cli-${release}-linux-x64-standalone.zip" || return 1
  mkdir -p $USRDIR || return 1
  unzip -q -d $USRDIR $dlpath || return 1
}

install_xcode() {
  if is_darwin && ! exists git; then
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
    PROD=$(softwareupdate -l |
      grep "\*.*Command Line" |
      head -n 1 | awk -F"*" '{print $2}' |
      sed -e 's/^ *//' |
      tr -d '\n')
    softwareupdate -i "$PROD" --verbose
    rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  else
    return 1
  fi
}

latest_release() {
  local repo=${1}
  if [ -z $repo ]; then
    echo repo argument is required > /dev/stderr
    return 1
  fi
  curl -s \
    -H "Accept: application/vnd.github+json" \
    https://api.github.com/repos/$repo/releases/latest | jq -r '.tag_name'
}

nofail() {
  if ! $@ ; then
    echo Failure: "$@"
    set -x
    $@ # do it again for debugging
    exit 1
  fi
}

whichor() {
  if ! whichq $1 ; then
    shift 1
    $@
  fi
}

whichq() {
  which $@ &>/dev/null
}

install_nix() {
  # install nix
  sh <(curl -L https://nixos.org/nix/install) 2>/dev/null --no-daemon

  [ -z "$USER" ] && USER=$user
  # source nix
  source $HOME/.nix-profile/etc/profile.d/nix.sh 

  # install packages
  nix-env -iA \
    nixpkgs.zsh \
    nixpkgs.antibody \
    nixpkgs.git \
    nixpkgs.neovim \
    nixpkgs.tmux \
    nixpkgs.stow \
    nixpkgs.yarn \
    nixpkgs.fzf \
    nixpkgs.ripgrep \
    nixpkgs.bat \
    nixpkgs.gnumake \
    nixpkgs.gcc \
    nixpkgs.direnv \
    nixpkgs.jq \
    nixpkgs.fd \
    nixpkgs.gh \
    nixpkgs.doctl \
    nixpkgs.rustup \
    nixpkgs.unzip
}

is_darwin && install_xcode
whichor nix-env nofail install_nix

export USRDIR=$HOME/usr
test -d $HOME/.nvm || install_nvm
test -d $USRDIR/balena-cli || install_balena

