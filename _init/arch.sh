set -x
arch_base() {
  pacman -Syyu --noconfirm --needed \
    base-devel \
    git \
    jq
}

install_nvim() {
  git clone git@github.com:$USER/config.neovim
  sudo pacman -S neovim --noconfirm
}

SRCDIR=$HOME/src
BINDIR="$HOME/dev/$USER/bin"

mkdir -p $SRCDIR
whichq git || arch_base
test -f $HOME/.gitconfig || config_git
whichq snap || install_snap
whichq gh || install_gh
gh auth status &>/dev/null || gh_login
test -f ~/.ssh/id_rsa || keygen
gh_config
gh_add_host_keys
test -d $HOME/bin || init_bin
local src_rc='source $HOME/dev/$USER/bin/_rc/'$1'.sh'
add_rc '$HOME/dev/$USER/bin/_rc/'linux.sh
add_rc '$HOME/dev/$USER/bin/_rc/'arch.sh
test -n $REINIT || copy_envs
whichq rustup || install_rustup
test -d $HOME/.nvm || install_nvm
whichq nvim || install_nvim
test ! -d $HOME/dev || copy_orgs
whichq doctl || install_doctl
doctl account get &>/dev/null || doctl_login
test -d $USR_DIR/balena-cli || install_balena
