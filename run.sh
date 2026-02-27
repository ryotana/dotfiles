#!/bin/bash

set -e
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME:+$FUNCNAME(): }'

if [ -z "$SUDO_USER" ]; then
  echo 'This script must be run with sudo'
  exit 1
fi

export USER=$SUDO_USER
export USERNAME=$SUDO_USER
export LOGNAME=$SUDO_USER

: functions
init() {
  BIN_PATH=$(dirname $0)
  MITAMAE_BOOTSTRAP='lib/bootstrap.rb'
  dry_run=true
}

usage_exit() {
  echo 'Usage:' 2>&1
  echo -e "\t `basename $0` [-x]" 2>&1
  exit 1
}

: main
init && while getopts xh OPT
do
  case $OPT in
    x)  dry_run=false
        ;;
    h)  usage_exit
        ;;
    \?) usage_exit
        ;;
  esac
done
shift $((OPTIND - 1))

if [ $dry_run = true ]; then
  bash $BIN_PATH/bin/mitamae local $BIN_PATH/$MITAMAE_BOOTSTRAP --dry-run
else
  bash $BIN_PATH/bin/mitamae local $BIN_PATH/$MITAMAE_BOOTSTRAP
fi
