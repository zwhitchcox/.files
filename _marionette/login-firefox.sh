#!/usr/ben/env bash
set -e
loginurl="https://accounts.firefox.com/?context=fx_desktop_v3&entrypoint=fxa_app_menu&action=email&service=sync"
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
type $loginurl
key enter
exit
key Tab
key Tab
key Tab
key enter
sleep 2
echo -n "enter your firefox email address: "
readline email
type $email
key enter
sleep 2
key ctrl+a
echo -n "firefox: "
read password
type $password
key enter
