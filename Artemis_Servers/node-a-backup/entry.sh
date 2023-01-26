#!/bin/sh

APP_NAME="backup server"

## Redirecting Filehanders
#ln -sf /proc/$$/fd/1 stdout.log
#ln -sf /proc/$$/fd/2 stderr.log

## Pre execution handler
pre_execution_handler() {
  ## Pre Execution
  # TODO: put your pre execution steps here
  echo "Started $APP_NAME" >> /app/stdout.log
}

## Post execution handler
post_execution_handler() {
  ## Post Execution
  # TODO: put your post execution steps here
  echo "Stopping $APP_NAME" >> /app/stdout.log
  /home/artemis/mybroker/bin/artemis-service stop
  echo "$APP_NAME stopped" >> /app/stdout.log
}

## Sigterm Handler
sigterm_handler() { 
  if [ $pid -ne 0 ]; then
    # the above if statement is important because it ensures 
    # that the application has already started. without it you
    # could attempt cleanup steps if the application failed to
    # start, causing errors.
    echo "SIGTERM handler: $APP_NAME" >> /app/stdout.log
    kill -15 "$pid"
    wait "$pid"
    post_execution_handler
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

sigquit_handler() {
echo "ERROR: $APP_NAME Called SIGQUIT handler instead of SIGTERM. Forwarding..." >> /app/stdout.log
sigterm_handler
}

sigint_handler() {
echo "ERROR: $APP_NAME Called SIGING handler instead of SIGTERM. Forwarding..." >> /app/stdout.log
sigterm_handler
}

## Setup signal trap
# on callback execute the specified handler
trap 'sigterm_handler' SIGTERM
trap 'sigterm_handler' SIGQUIT
trap 'sigterm_handler' SIGINT

## Initialization
pre_execution_handler

## Start Process
# run process in background and record PID
>>/app/stdout.log 2>>/app/stderr.log "$@" &

# IMPORTANT: don't attach to stdou.log as that would cause an infinite loop of outputs!
tail -f /app/stderr.log &

pid=$!
echo "PID: $pid" >>/app/stdout.log
ps -e >>/app/stdout.log

## Wait forever until app dies
# IMPORTANT: wait requires for the $pid to a child of this shell, not just
# some random PID you grabbed from ps -e.
wait $pid
#tail --pid=$pid -f /app/test_dump.txt 

return_code="$?"

echo "cleaning up $APP_NAME" >>/app/stdout.log
ps -e >> /app/stdout.log

## Cleanup
post_execution_handler
# echo the return code of the application
exit $return_code
