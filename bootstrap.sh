err_exit() {
  echo "$@" 1>&2
  exit 1
}

# create source directory
pushd $HOME
mkdir -p src
pushd src

# clone this repo and switch to it
git clone --recurse-submodules git@github.com:zwhitchcox/.files
pushd .files

# install nix packages
bash install/nix_pkgs.sh

# add ssh keys
bash init/keys.sh

# login to different sites
bash init/login.sh

# initialize user preferences
bash init/init.sh

# install nvm
bash install/nvm.sh

# install balena cli
bash install/balena.sh
