#!/usr/ben/env bash
set -e
nohup firefox --private -P zwhitchcox &>/dev/null & 

sleep 1
winid=$(wmctrl -l | grep -i firefox | tail -n 1 | awk '{print $1}')
if [ -z $winid ]; then
  echo could not find window 1>&2
  exit 1
fi
key() {
  xdotool key --delay=20 --window $winid --clearmodifiers $@
}
type() {
  xdotool type --window $winid $@
}
sleep 1
key ctrl+l
type "gmail.com"
key enter
key Tab
key Tab
key Tab
key enter
sleep 2
echo -n "enter your gmail email address: "
readline email
type $email
type "zwhitchox@gmail.com"
key enter
sleep 2
key ctrl+a
echo -n "enter your gmail password: "
readline password
type $password
key enter
