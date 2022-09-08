err_exit() {
  echo "Could not find init for $(uname -a)" 1>&2
}

init_nix() {
  bash install/nix_pkgs.sh
  bash install/nvm.sh
  bash install/balena.sh
  bash init/keys.sh
  bash init/login.sh
  bash init/init.sh
}

[ -d /etc/nixos ] && init_nix && exit

# todo: add installations for other OS's
