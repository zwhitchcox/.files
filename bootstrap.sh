#!/usr/bin/env bash
cd $HOME

err_exit() {
  echo "$@" 1>&2
  exit 1
}
if [ -z "$GH_TOKEN" ]; then
  err_exit Need GH_TOKEN
fi

keygen() {
  local key_file=$HOME/.ssh/id_rsa
  [ -f $key_file ] && return 0
  set -e
  local email="$(curl \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token $GH_TOKEN" \
    https://api.github.com/user/emails | jq -r '.[] | select(.primary == true) | .email')"
  mkdir -p $HOME/.ssh
  ssh-keygen -C $email -t rsa -b 4096 -f $key_file -P ''
  set +e
}

add_key() {
  local output=$(
    curl -s \
      -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GH_TOKEN" \
      -d '{"key": "'"$(cat $HOME/.ssh/id_rsa.pub)"'", "title": "'"$(cat /etc/hostname)"'"' \
      https://api.github.com/user/keys
  )
  #TODO test for error
  test $? -eq 0 && return
  if ! echo $output | grep -q "key is already in use"; then
    echo -e "could not add key\n$output" > /dev/stderr
    exit 1
  else
    echo "key already added" 1>&2
  fi
}

# add github host keys to known hosts
gh_add_host_keys() {
  local key_file=$HOME/.ssh/known_hosts
  local keys=$(ssh-keyscan -H github.com 2>/dev/null)
  (echo $keys ; cat $key_file) | sort | uniq -u > $key_file
}

set -e
gh_add_host_keys
keygen
add_key
set -x
[ ! -d $HOME/dev ] && git clone --recurse-submodules -j8 git@github.com:$USER/dev
cd $HOME/dev/$USER/bin

source init.sh
