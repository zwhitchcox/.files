err_exit() {
  echo "$@" 1>&2
  exit 1
}


clone_src() {
  GH_USER=${GH_USER:-$USER}
  if [ ! -d $HOME/src ]; then
    git clone --recurse-submodules -j8 git@github.com:$GH_USER/dev
  fi
}

# dev
clone_src
mkdir -p ~/.config
ln -sf $HOME/dev/$USER/config.nvim $HOME/.config/nvim

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
