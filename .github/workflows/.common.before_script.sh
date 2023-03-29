#!/bin/bash
set -e

run () {
  PREFIX=$(if [[ "$DRY_RUN" == "1" ]]; then echo "dry run"; else echo "run"; fi)
  echo "$PREFIX: $*"
  if [[ "$DRY_RUN" == "1" ]]; then
    return 0
  fi
  eval "$@"
}

use_printf=`printf "%(true)T\n" -1 2>/dev/null` || use_printf=false
use_awk=`awk 'BEGIN{print(strftime("true"));}'` || use_awk=false
echo "logging: use_printf=$use_printf; use_awk=$use_awk"
if $use_printf ; then
  logging_pipe=/tmp/$$.logging
  mkfifo $logging_pipe
  (set +x;while read -r line;do printf "%(%H:%M:%S)T  %s\n" -1 "$line";done) <$logging_pipe&
  exec >$logging_pipe 2>&1
  rm $logging_pipe
elif $use_awk ; then
  logging_pipe=/tmp/$$.logging
  mkfifo $logging_pipe
  awk '{printf("%s  %s\n",strftime("%H:%M:%S"),$0);}' <$logging_pipe&
  exec >$logging_pipe 2>&1
  rm $logging_pipe
else
  echo "Can't setup timestamped logging."
fi
echo "logging: Started."
