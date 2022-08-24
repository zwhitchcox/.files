config_git() {
  local gc="git config --global user"
  test -n $gc.email || $gc.email $GIT_EMAIL
  test -n $gc.name || $gc.email $GIT_NAME
}

install_snap() {
  git clone https://aur.archlinux.org/snapd.git $SRCDIR
  sudo systemctl enable --now snapd.socket
  sudo ln -s /var/lib/snapd/snap /snap
}

install_gh() {
  sudo snap install gh
}

gh_login() {
  echo $_GH_TOKEN | gh auth login \
    -h github.com \
    -p ssh \
    --with-token 
}

keygen() {
  ssh-keygen -C $GIT_EMAIL -t rsa -b 4096 -f $HOME/.ssh/id_rsa -P ''
}


# get list of keys
gh_list_keys() {
  curl \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token $_GH_TOKEN" \
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
  output=$(cat $HOME/.ssh/id_rsa.pub | gh ssh-key add  -t $(cat /etc/hostname) 2>&1)
  test $? -eq 0 && return
  if ! echo $output | grep -q "key is already in use"; then
    echo -e "could not add key\n$output" > /dev/stderr
    exit 1
  fi
}

# add github host keys to known hosts
gh_add_host_keys() {
  local key_file=$HOME/.ssh/known_hosts
  local keys=$(ssh-keyscan -H github.com 2>/dev/null)
  (echo $keys ; cat $key_file) | sort | uniq -u > $key_file
}

init_bin() {
  pushd $HOME
  git clone git@github.com:$GH_USERNAME/bin.git $BINDIR || exit 1
  cd $BINDIR
  popd
}

add_rc() {
  local src_rc="source $BINDIR/_dotfiles/${1}.rc"
  grep -q "$src_rc" $HOME/$(rcfile) || echo $src_rc >> $HOME/$(rcfile)
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
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

install_nvm() {
  local release=$(gh release list -R nvm-sh/nvm --limit 1 | awk '{print $1}')
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${release}/install.sh | bash
}

install_nvim() {
  git clone git@github.com:$GH_USERNAME/config.neovim
  sudo pacman -S neovim
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