#!/usr/bin/env bash
USRDIR=$HOME/usr

if test -d $USRDIR/balena-cli; then
  echo balena already installed 1>&2
  exit 0
fi

mkdir -p $USRDIR

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

release=$(latest_release balena-io/balena-cli)
dlpath=/tmp/balena-cli.zip
curl -sL -o $dlpath "https://github.com/balena-io/balena-cli/releases/download/${release}/balena-cli-${release}-linux-x64-standalone.zip"
unzip -q -d $USRDIR $dlpath

echo add $USRDIR/balena-cli to your PATH to use
