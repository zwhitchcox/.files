#!/usr/bin/env bash

if [ "$(uname -s)" != "Darwin" ]; then
  echo this can only be run on Mac OS X
  exit 1
fi

if [ -z "$(command -v git)" ]; then
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
  PROD=$(softwareupdate -l |
    grep "\*.*Command Line" |
    head -n 1 | awk -F"*" '{print $2}' |
    sed -e 's/^ *//' |
    tr -d '\n')
  softwareupdate -i "$PROD" --verbose
  rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
fi
