#!/usr/bin/env

if test -d $HOME/.nvm; then
  echo nvm is already installed 1>&2
  exit 1
fi

latest_release() {
  local repo=${1}
  if [ -z $repo ]; then
    echo repo argument is required > /dev/stderr
    return 1
  fi
  curl -s \
    -H "Accept: application/vnd.github+json" \
    https://api.github.com/repos/$repo/releases/latest | jq -r '.tag_name'
}


release=$(latest_release nvm-sh/nvm) || return 1
curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/${release}/install.sh | bash
