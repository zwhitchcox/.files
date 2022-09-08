err_exit() {
  echo "$@" 1>&2
  exit 1
}

# nvim
mkdir -p ~/.config
ln -sf $HOME/src/$USER/config.nvim $HOME/.config/nvim

BINDIR=$HOME/bin
mkdir -p $BINDIR
# stow dotfiles
stow -t $BINDIR bin/*
stow -t $HOME _/*

# add zsh as a login shell
command -v zsh | sudo tee -a /etc/shells

# use zsh as default shell
sudo chsh -s $(which zsh) $USER

# bundle zsh plugins 
antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh

# install neovim plugins
nvim --headless +PlugInstall +qall
