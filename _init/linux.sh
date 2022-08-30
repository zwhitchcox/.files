install_snap() {
  git clone https://aur.archlinux.org/snapd.git $SRCDIR
  sudo systemctl enable --now snapd.socket
  sudo ln -s /var/lib/snapd/snap /snap
}

install_gh() {
  sudo snap install gh
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

gh_config() {
  output=$(cat $HOME/.ssh/id_rsa.pub | gh ssh-key add -t $(cat /etc/hostname) 2>&1)
  test $? -eq 0 && return
  if ! echo $output | grep -q "key is already in use"; then
    echo -e "could not add key\n$output" > /dev/stderr
    exit 1
  fi
}


init_bin() {
  pushd $HOME
  git clone git@github.com:$GH_USERNAME/bin.git $BINDIR || exit 1
  cd $BINDIR
  popd
}

add_rc() {
  local src_rc="source $1"
  grep -q "$src_rc" $HOME/$(rcfile) || echo $src_rc >> $HOME/$(rcfile)
}

ln_dotfiles() {
  ln -s $BINDIR/_dotfiles/.tmux.conf $HOME/.tmux.conf
  ln -s $BINDIR/_dotfiles/.vimrc $HOME/.vimrc
  ln -s $BINDIR/_dotfiles/.gitconfig $HOME/.gitconfig
}

copy_envs() {
  ls ./env/* | grep -v init | cpio -pvd $HOME &>/dev/null
}

whichq() {
  which $@ &>/dev/null
}

rcfile() {
  echo -e ".$(basename $(echo -e $SHELL))rc"
}

err_exit() {
  echo $@ > /dev/stderr
  exit 1
}

install_rustup() {
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  #curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

install_nvm() {
  local release=$(gh release list -R nvm-sh/nvm --limit 1 | awk '{print $1}')
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${release}/install.sh | bash
}


copy_orgs() {
  if test -f $PROJPATH/organizations; then
    for org in `cat $PROJPATH/organizations`; do
      mkdir -p $HOME/dev/$org
    done
  fi
}

install_doctl() {
  sudo snap install doctl
}

doctl_login() {
  doctl auth init &>/dev/null
}

install_balena() {
  set -e
  local release=$(bash $BINDIR/git/latest_release balena-io/balena-cli)
  local dlpath=/tmp/balena-cli.zip
  curl -L -o $dlpath "https://github.com/balena-io/balena-cli/releases/download/${release}/balena-cli-${release}-linux-x64-standalone.zip"  
  mkdir -p $USR_DIR
  unzip -d $USR_DIR $dlpath 
  set +e
}
