#!/usr/bin/env bash

# source nix
source $HOME/.profile
source $HOME/.bashrc

nix-env -iA nixpkgs.openssh
