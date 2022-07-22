### Install Unix

#### Clone repo

```
pushd $HOME
git clone git@github.com:zwhitchcox/bin
popd
```

#### Add dirs to path
```
DIRS=(
  git
  unix
)
platform=$(uname -s | tr '[:upper:]' '[:lower:]')
rcfile=.bashrc
if [ $platform == darwin ];
  rcfile=.zshrc
  DIRS+=(mac)
fi

BIN_BASE=$HOME/bin
for dir in ${DIRS[@]}; do
  echo 'export PATH=$PATH:$BIN_BASE/$dir' >> $HOME/$rcfile
done
```