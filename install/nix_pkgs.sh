#!/usr/bin/env bash

# source nix
[ -f $HOME/.profile ] && source $HOME/.profile
[ -f $HOME/.bashrc ] && source $HOME/.bashrc

# install packages
nix-env -iA \
  nixpkgs.zsh \
  nixpkgs.antibody \
  nixpkgs.git \
  nixpkgs.neovim \
  nixpkgs.tmux \
  nixpkgs.stow \
  nixpkgs.yarn \
  nixpkgs.fzf \
  nixpkgs.ripgrep \
  nixpkgs.bat \
  nixpkgs.gnumake \
  nixpkgs.gcc \
  nixpkgs.direnv \
  nixpkgs.jq \
  nixpkgs.fd \
  nixpkgs.gh \
  nixpkgs.doctl \
  nixpkgs.rustup \
  nixpkgs.unzip \
  nixpkgs.home-manager
