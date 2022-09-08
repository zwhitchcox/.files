err_exit() {
  echo "$@" 1>&2
  exit 1
}

# nvim
git clone git@github.com:$USER/config.nvim $HOME/src/$USER/config.nvim
mkdir -p ~/.config
if [ -d $HOME/.config/nvim ]; then
  echo $HOME/.config/nvim already exists. Not overwriting 1>&2
else
  ln -sf $HOME/src/$USER/config.nvim $HOME/.config/nvim
fi

BINDIR=$HOME/bin
mkdir -p $BINDIR
# stow dotfiles
stow -t $BINDIR bin/*
stow -t $HOME _/*

# add zsh as a login shell
command -v zsh | sudo tee -a /etc/shells

# use zsh as default shell
sudo chsh -s $(which zsh) $USER

# install neovim plugins
nvim --headless +PlugInstall +qall
