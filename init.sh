# pushd $HOME
# git clone git@github.com:zwhitchcox/bin
# popd

DIRS=(
  git
  unix
)
platform=$(uname -s | tr '[:upper:]' '[:lower:]')
rcfile=.bashrc
if [ $platform == darwin ]; then
  rcfile=.zshrc
  DIRS+=(mac)
fi

for dir in ${DIRS[@]}; do
  echo 'export PATH=$PATH:$HOME/bin'/$dir >> $HOME/$rcfile
done
