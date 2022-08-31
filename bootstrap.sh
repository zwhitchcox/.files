#!/usr/bin/env bash
sudo echo -n '' # acquire sudo permissions early

export PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')

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
  if [ $PLATFORM == linux ]; then
    if exists pacman; then
      pacman -Syyu --noconfirm
    elif exists apt; then
      apt update -y
    else
      err_exit "could not find your platform"
      exit 1
    fi
  elif [ $PLATFORM == darwin ]; then
    : # brew does this automatically
  else
    err_exit "could not find your platform"
  fi
}

# package installer
pkg_apt() {
  if [ $PLATFORM == linux ] && exists apt; then
    sudo apt install -y $@
    return $?
  fi
  return 1
}

pkg_pacman() {
  if [ $PLATFORM == linux ] && exists pacman; then
    sudo pacman -S --noconfirm $@
    return $?
  fi
  return 1
}

pkg_brew() {
  if ! exists brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [ $PLATFORM == darwin ]; then
    brew install $@
    return $?
  fi
  return 1
}

pkg_snap() {
  if [ $platform == linux ] && exists snap; then
    snap install $@
    return $?
  fi
  return 1
}

pkg_all() {
  pkg_pacman $1 || pkg_brew $1 || pkg_apt $1 || pkg_snap $1
}

check_token() {
  if [ -z "$GH_TOKEN" ]; then
    if [ -n "$KEYFILE" ]; then
      source $KEYFILE
    fi
    err_exit Need GH_TOKEN
  fi
}

keygen() {
  local key_file=$HOME/.ssh/id_rsa
  [ -f $key_file ] && return 0
  set -e
  local email="$(curl \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token $GH_TOKEN" \
    https://api.github.com/user/emails | jq -r '.[] | select(.primary == true) | .email')"
  mkdir -p $HOME/.ssh
  ssh-keygen -C $email -t rsa -b 4096 -f $key_file -P ''
  set +e
}

add_key() {
  local output=$(
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
    exit 1
  else
    echo "key already added" 1>&2
  fi
}

# add github host keys to known hosts
gh_add_host_keys() {
  local key_file=$HOME/.ssh/known_hosts
  local keys=$(ssh-keyscan -H github.com 2>/dev/null)
  (echo $keys ; cat $key_file) | sort | uniq -u > $key_file
}


install_snap() {
  if [ $PLATFORM == linux ]; then
    git clone https://aur.archlinux.org/snapd.git $SRCDIR
    sudo systemctl enable --now snapd.socket
    sudo ln -s /var/lib/snapd/snap /snap
  fi
}

gh_login() {
  echo $GH_TOKEN | gh auth login \
    -h github.com \
    -p ssh \
    --with-token
}

keygen() {
  set -e
  local email="$(curl \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token $GH_TOKEN" \
    https://api.github.com/user/emails | jq -r '.[] | select(.primary == true) | .email')"
  ssh-keygen -C $email -t rsa -b 4096 -f $HOME/.ssh/id_rsa -P ''
  set +e
}

# get list of keys
gh_list_keys() {
  curl \
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
  curl \
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
  set -x
  for base in $(ls -a $BINDIR/_dotfiles | grep -Ev '^\.+$'); do
    local target=$BINDIR/_dotfiles/$base
    local source=$HOME/$(basename $target)
    if [ -L $source ]; then
      [ "$(readlink $source)" != $target ] && err_exit "$target already exists"
    elif [ -f $source ]; then
      err_exit "$target already exists"
    else
      ln -s $target $source
    fi
  done
  set +x
}

whichq() {
  which $@ &>/dev/null
}

rcfile() {
  echo -e ".$(basename $(echo -e $SHELL))rc"
}

install_rustup() {
  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y
}

install_nvm() {
  local release=$(gh release list -R nvm-sh/nvm --limit 1 | awk '{print $1}')
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${release}/install.sh | bash
}


doctl_login() {
  doctl auth init &>/dev/null
}

install_balena() {
  set -e
  local release=$(bash $BINDIR/git/latest_release balena-io/balena-cli)
  local dlpath=/tmp/balena-cli.zip
  curl -L -o $dlpath "https://github.com/balena-io/balena-cli/releases/download/${release}/balena-cli-${release}-linux-x64-standalone.zip"
  mkdir -p $USRDIR
  unzip -d $USRDIR $dlpath
  set +e
}

base_pkg() {
  whichq make || pkg_pacman base-devel git jq
  whichq make || pkg_apt build-essential unzip jq
  whichq make || base_darwin
}


base_darwin() {
  if [ $PLATFORM == darwin ] && ! exists git; then
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
    PROD=$(softwareupdate -l |
      grep "\*.*Command Line" |
      head -n 1 | awk -F"*" '{print $2}' |
      sed -e 's/^ *//' |
      tr -d '\n')
    softwareupdate -i "$PROD" --verbose
    rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  fi
}

install_nvim() {
  set -e
  mkdir -p ~/.config
  ln -sf $HOME/dev/$USER/config.nvim $HOME/.config/nvim
  whichq nvim || pkg_all neovim
  set +e
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
export BINDIR=$HOME/dev/$USER/bin
export USRDIR=$HOME/usr
export SRCDIR=$HOME/src

mkdir -p $SRCDIR
mkdir -p $USRDIR

# packages
update_sources
base_pkg
whichq snap || install_snap
whichq rustup || install_rustup
whichq gh || pkg_all gh
whichq doctl || pkg_all doctl
whichq jq || pkg_all jq
whichq rg || pkg_all ripgrep
whichq tmux || pkg_all tmux
whichq fzf || pkg_all fzf
install_nvim
test -d $HOME/.nvm || install_nvm
test -d $USRDIR/balena-cli || install_balena

# config gh
gh_keys
gh auth status &>/dev/null || gh_login

# config doctl
doctl account get &>/dev/null || doctl_login

# dev
clone_dev
ln_dotfiles
add_rc '$HOME/.rc.sh'
