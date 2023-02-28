todo: replace: replace all files in directory
todo: system clipboard over ssh

### example
remote install on server rsync -r . zwhitchcox.dev:$PWD && ssh -t zwhitchcox.dev "$(cat ../key/key.env | sed -z 's/\n/; /g') bash $PWD/init.sh"

install oh-my-zsh:

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

```
