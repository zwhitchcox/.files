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

log() {
  if $BOOTSTRAP_VERBOSE; then
    echo "$@" 1>&2
  fi
}

# this script can have no dependencies
err_exit() {
  echo "$@" 1>&2
  exit 1
}

exists() {
  command -v $1 &>/dev/null
  return $?
}

update_sources() {
  if is_darwin || is_linux; then
    return 0 # automatic
  fi
  if is_linux; then
    if exists pacman; then
      pacman -Syyu --noconfirm
    elif exists apt; then
      apt update -y
    else
      err_exit "could not find your platform"
      exit 1
    fi
  else
    err_exit "could not find your platform"
  fi
}

install_snap() {
  if is_linux; then
    git clone https://aur.archlinux.org/snapd.git $SRCDIR || return 1
    sudo systemctl enable --now snapd.socket || return 1
    sudo ln -s /var/lib/snapd/snap /snap || return 1
  fi
}

# package installer
pkg_apt() {
  if is_linux && exists apt; then
    echo installing $@ from apt
    local output=$(sudo apt install -y $@ 2>&1)
    if [ "$?" != "0" ]; then
      echo "$output" 1>&2
      return 1
    fi
    return 0
  fi
  return 1
}

pkg_pacman() {
  if is_linux && exists pacman; then
    echo installing $@ from pacman
    local output=$(pacman -S --noconfirm $@ 2>&1)
    if [ "$?" != "0" ]; then
      echo "$output" 1>&2
      return 1
    fi
    return 0
  fi
  return 1
}

pkg_brew() {
  if is_darwin; then
    if ! exists brew; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    echo installing $@ from snap
    local output=$(brew install $@ 2>&1)
    if [ "$?" != "0" ]; then
      echo "$output" 1>&2
      return 1
    fi
    return $0
  fi
  return 1
}

pkg_snap() {
  if is_linux && exists snap; then
    echo installing $@ from snap
    local output=$(snap install $@ 2>&1)
    if [ "$?" != "0" ]; then
      echo "$output" 1>&2
      return 1
    fi
    return $0
  fi
  return 1
}

pkg_balena() {
  if is_linux && is_balena; then
    echo installing $@ from balena
    local output
    output=$(install_packages $@  2>&1)
    if [ "$?" != "0" ]; then
      echo "$output" 1>&2
      return 1
    fi
    return 0
  fi
  return 1
}

pkg_all() {
  pkg_pacman $1 || pkg_brew $1 || pkg_apt $1 || pkg_snap $1 || pkg_balena $1
}

check_token() {
  if [ -z "$GH_TOKEN" ]; then
    if [ -n "$KEYFILE" ]; then
      source $KEYFILE || return 1
    fi
    err_exit Need GH_TOKEN
  fi
}

keygen() {
  local key_file=$HOME/.ssh/id_rsa
  [ -f $key_file ] && return 0
  local email
  email="$(curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token $GH_TOKEN" \
    https://api.github.com/user/emails | jq -r '.[] | select(.primary == true) | .email')" || return 1
  mkdir -p $HOME/.ssh || return 1
  ssh-keygen -C $email -t rsa -b 4096 -f $key_file -P ''
}

add_key() {
  local output
  output=$(
    curl -s \
      -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GH_TOKEN" \
      -d '{"key": "'"$(cat $HOME/.ssh/id_rsa.pub)"'", "title": "'"$(hostname)"'"' \
      https://api.github.com/user/keys
  )
  #TODO test for error
  test $? -eq 0 && return
  if ! echo $output | grep -q "key is already in use"; then
    echo -e "could not add key\n$output" > /dev/stderr
    return 1
  else
    echo "key already added" 1>&2
  fi
}

# add github host keys to known hosts
gh_add_host_keys() {
  local key_file
  local keys
  key_file=$HOME/.ssh/known_hosts
  keys=$(ssh-keyscan -H github.com 2>/dev/null) || return 1
  (echo $keys ; cat $key_file) | sort | uniq -u > $key_file
}


gh_login() {
  echo $GH_TOKEN | gh auth login \
    -h github.com \
    -p ssh \
    --with-token
}

keygen() {
  local email
  email=$(curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token $GH_TOKEN" \
    https://api.github.com/user/emails | jq -r '.[] | select(.primary == true) | .email') || return 1
  ssh-keygen -C $email -t rsa -b 4096 -f $HOME/.ssh/id_rsa -P ''
}

# get list of keys
gh_list_keys() {
  curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token $GH_TOKEN" \
    https://api.github.com/user/keys
}

# get key by title
gh_key_by_title() {
  list_keys | jq -r '.[] | "\(.id) \(.title)"'
}

# delete ssh key
gh_key_del() {
  local KEY_ID=$1
  curl -s \
    -X DELETE \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token $GH_TOKEN" \
    https://api.github.com/user/keys/$KEY_ID
}

add_rc() {
  local src_rc="source $1"
  grep -q "$src_rc" $HOME/$(rcfile) || echo $src_rc >> $HOME/$(rcfile)
}

ln_dotfiles() {
  local target
  local source
  for base in $(ls -a $BINDIR/_dotfiles | grep -Ev '^\.+$' || return 1); do
    target=$BINDIR/_dotfiles/$base
    source=$HOME/$(basename $target) || return 1
    if [ -L $source ]; then
      [ "$(readlink $source)" != $target ] && err_exit "$target already exists"
    elif [ -f $source ]; then
      err_exit "$target already exists"
    else
      ln -s $target $source || return 1
    fi
  done
}

whichq() {
  which $@ &>/dev/null
}

rcfile() {
  echo -e ".$(basename $(echo -e $SHELL))rc" || return 1
}

install_rustup() {
  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y || return 1
}

install_nvm() {
  local release
  release=$(gh release list -R nvm-sh/nvm --limit 1 | awk '{print $1}') || return 1
  curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/${release}/install.sh | bash || return 1
}


doctl_login() {
  doctl auth init &>/dev/null || return 1
}

install_balena() {
  local release
  release=$(bash $BINDIR/git/latest_release balena-io/balena-cli)
  local dlpath=/tmp/balena-cli.zip
  curl -sL -o $dlpath "https://github.com/balena-io/balena-cli/releases/download/${release}/balena-cli-${release}-linux-x64-standalone.zip" || return 1
  mkdir -p $USRDIR || return 1
  unzip -q -d $USRDIR $dlpath || return 1
}

base_pkg() {
  whichq make || pkg_balena build-essential unzip jq \
    || pkg_pacman base-devel git jq \
    || pkg_apt build-essential unzip jq \
    || base_darwin \
    || pkg_all build-essential unzip jq
}


base_darwin() {
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

clone_dev() {
  GH_USER=${GH_USER:-$USER}
  if [ ! -d $HOME/dev ]; then
    git clone --recurse-submodules -j8 git@github.com:$GH_USER/dev
  fi
}

gh_keys() {
  gh_add_host_keys
  test -f ~/.ssh/id_rsa || keygen
  add_key
}

### MAIN ###
export BINDIR="$(echo "$HOME/dev/$USER/bin" | sed 's/\/\//\//g')"
export USRDIR=$HOME/usr
export SRCDIR=$HOME/src
export USER=$(whoami)
echo $USER

mkdir -p $SRCDIR
mkdir -p $USRDIR


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

should_snap() {
  ! is_balena || is_darwin # no snap support
}

# packages
update_sources
base_pkg

whichor git        nofail pkg_all git
whichor snap       'should_snap || nofail install_snap'
whichor gh         'should_snap || nofail pkg_snap gh'
whichor doctl      'should_snap || nofail pkg_snap doctl'
whichor rustup     nofail install_rustup
whichor jq         nofail pkg_all jq
whichor rg         nofail pkg_all ripgrep
whichor tmux       nofail pkg_all tmux
whichor fzf        nofail pkg_all fzf
whichor nvim       nofail pkg_all neovim
whichor fd         nofail pkg_all fd
test -d $HOME/.nvm || install_nvm
test -d $USRDIR/balena-cli || install_balena

is_balena &&  exit

# config gh
gh_keys
gh auth status &>/dev/null || gh_login

# config doctl
doctl account get &>/dev/null || doctl_login

# dev
clone_dev
ln_dotfiles
add_rc '$HOME/.rc.sh'
mkdir -p ~/.config
ln -sf $HOME/dev/$USER/config.nvim $HOME/.config/nvim
