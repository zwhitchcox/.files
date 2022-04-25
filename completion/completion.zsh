#/usr/bin/env zsh

_completion_remote_run() {
  hosts=($(sed -e 's/#.*//' -e 's/[[:blank:]]*$//' -e '/^$/d' /etc/hosts | awk '{print $2}' | egrep -v '(local|broadcast)host|kubernetes'))
  for host in ${hosts[@]}; do
    compadd $host remote_run
  done
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
  for prog in `ls $DIR`; do
    if [ -x $prog ] && ! [ -d $prog ]; then
      compadd $prog remote_run
    fi
  done
}

compdef _completion_remote_run remote_run