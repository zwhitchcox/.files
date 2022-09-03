#!/usr/bin/env bash

# source nix
source $HOME/.profile

nix-env -iA nixpkgs.openssh
