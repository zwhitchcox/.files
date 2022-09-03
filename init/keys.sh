# # get list of keys
# gh_list_keys() {
#   curl -s \
#     -H "Accept: application/vnd.github+json" \
#     -H "Authorization: token $GH_TOKEN" \
#     https://api.github.com/user/keys
# }
#
# # get key by title
# gh_key_by_title() {
#   list_keys | jq -r '.[] | "\(.id) \(.title)"'
# }
#
# # delete ssh key
# gh_key_del() {
#   local KEY_ID=$1
#   curl -s \
#     -X DELETE \
#     -H "Accept: application/vnd.github+json" \
#     -H "Authorization: token $GH_TOKEN" \
#     https://api.github.com/user/keys/$KEY_ID
# }

check_token() {
  if [ -z "$GH_TOKEN" ]; then
    if [ -n "$KEYFILE" ]; then
      source $KEYFILE || return 1
    fi
    err_exit Need GH_TOKEN
  fi
}

keygen() {
  local key_file=$HOME/.ssh/id_rsa
  [ -f $key_file ] && return 0
  local email
  email="$(curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token $GH_TOKEN" \
    https://api.github.com/user/emails | jq -r '.[] | select(.primary == true) | .email')" || return 1
  mkdir -p $HOME/.ssh || return 1
  ssh-keygen -C $email -t rsa -b 4096 -f $key_file -P ''
}

add_key() {
  local output
  output=$(
    curl -s \
      -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GH_TOKEN" \
      -d '{"key": "'"$(cat $HOME/.ssh/id_rsa.pub)"'", "title": "'"$(hostname)"'"' \
      https://api.github.com/user/keys
  )
  #TODO test for error
  test $? -eq 0 && return
  if ! echo $output | grep -q "key is already in use"; then
    echo -e "could not add key\n$output" > /dev/stderr
    return 1
  else
    echo "key already added" 1>&2
  fi
}


# add github host keys to known hosts
gh_add_host_keys() {
  local key_file
  local keys
  key_file=$HOME/.ssh/known_hosts
  keys=$(ssh-keyscan -H github.com 2>/dev/null) || return 1
  (echo $keys ; cat $key_file) | sort | uniq -u > $key_file
}

gh_keys() {
  gh_add_host_keys
  test -f ~/.ssh/id_rsa || keygen
  add_key
}
# config gh
check_token
gh_keys
