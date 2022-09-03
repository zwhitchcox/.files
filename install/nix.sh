#!/usr/bin/env bash

if [ -n "$(command -v nix-env)" ]; then
  echo nix is already installed 1>&2
  exit 0
fi

if [ "$UID" == 0 ]; then
  echo cannot install as root 1>&2
  exit 1
fi

# install nix
sh <(curl -L https://nixos.org/nix/install) 2>/dev/null --no-daemon
