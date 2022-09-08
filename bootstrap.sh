# bash <(curl -l -H 'Authorization: token '$GH_TOKEN \
#   -H 'Accept: application/vnd.github.v3.raw' \
#   -L https://api.github.com/repos/zwhitchcox/.files/contents/bootstrap.sh)

err_exit() {
  echo "$@" 1>&2
  exit 1
}

check_token() {
  [ -z "$GH_TOKEN" ] &&  err_exit "This script requires GH_TOKEN to be set."
}

create_src() {
  # create source directory
  pushd $HOME
  mkdir -p src
  pushd src
}

clone_dotfiles() {
  # clone this repo and switch to it
  git clone --recurse-submodules https://oauth2:$GH_TOKEN@github.com/zwhitchcox/.files.git
  pushd .files
}

check_token
create_src
clone_dotfiles

bash init.sh

popd # .files
popd # src
popd # $HOME
