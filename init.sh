#!/usr/bin/env bash
sudo echo -n '' # acquire sudo permissions early
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )" # get current dir
export PROJPATH=$SCRIPTPATH/..
export ENVPATH=$PROJPATH/env
export USR_DIR=$HOME/usr

if [ $(uname -s | tr '[:upper:]' '[:lower:]') == linux ]; then
  source $SCRIPTPATH/_init/linux.sh
fi

if lsb_release -i | grep -qi manjaro ; then
  source $SCRIPTPATH/_init/arch.sh
else
  echo no script for installing your os. please add one to ./bin/_init
fi
