#!/usr/bin/env bash

err_exit() {
  echo "$@" 1>&2
  exit 1
}

log() {
  echo "$@" 1>&2
}

gh_login() {
  echo $GH_TOKEN | gh auth login \
    -h github.com \
    -p ssh \
    --with-token
}

doctl_login() {
  doctl auth init &>/dev/null || return 1
}

# need DIGITALOCEAN_ACCESS_TOKEN 
if ! doctl account get &>/dev/null; then
  if [ -z "$DIGITALOCEAN_ACCESS_TOKEN" ]; then
    log DIGITALOCEAN_ACCESS_TOKEN not set, skipping doctl login
  else
    if ! doctl auth init &>/dev/null; then
      log "Couldn't log in to digital ocean"
    fi
  fi
fi

# need GH_TOKEN
gh auth status &>/dev/null || gh_login
