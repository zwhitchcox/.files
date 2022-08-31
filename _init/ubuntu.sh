ubuntu_base() {
  sudo apt install -y build-essential unzip
}

install_nvim() {
  set -e
  mkdir -p ~/.config
  ln -sf $HOME/dev/$USER/config.nvim $HOME/.config/nvim
  sudo apt install -y neovim
  set +e
}

SRCDIR=$HOME/src
BINDIR="$HOME/dev/$USER/bin"

mkdir -p $SRCDIR
whichq make || ubuntu_base
test -f $HOME/.gitconfig || config_git
whichq snap || install_snap
whichq gh || install_gh
gh auth status &>/dev/null || gh_login
test -f ~/.ssh/id_rsa || keygen
gh_config
add_rc '$HOME/dev/$USER/bin/_rc/linux.sh'
add_rc '$HOME/dev/$USER/bin/_rc/ubuntu.sh'
test -n $REINIT || copy_envs
whichq rustup || install_rustup
test -d $HOME/.nvm || install_nvm
install_nvim
test ! -d $HOME/dev || copy_orgs
whichq doctl || install_doctl
doctl account get &>/dev/null || doctl_login
test -d $USR_DIR/balena-cli || install_balena
