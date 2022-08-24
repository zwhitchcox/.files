sudo echo -n '' # acquire sudo permissions early
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PROJPATH=$SCRIPTPATH/../..
ENVPATH=$PROJPATH/env

if [ -z $REINIT ]; then
  # get environment variables
  source $ENVPATH/base_env
  source $ENVPATH/init_env
fi

# get utils functions
source $SCRIPTPATH/util.sh

arch_base() {
  pacman -Syyu --noconfirm --needed \
    base-devel \
    git \
    jq
}

SRCDIR=$HOME/src
BINDIR=$HOME/bin

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
add_rc common
add_rc arch
test -n $REINIT && copy_envs
whichq rustup || install_rustup
test -d $HOME/.nvm || install_nvm
whichq nvim || install_nvim
