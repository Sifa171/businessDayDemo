#!/bin/bash

# Check if logging is enabled
if [ -n $OUTPUT_LOG ]
then
  if [ "$OUTPUT_LOG" == "true" ]
  then
    # show log message
    echo "Analyze-adv pod started in container $(hostname)"
    sleep 10
    echo "10 seconds passed"
    echo "Started..." > /tmp/startup.log
  fi
fi

exec /bin/bash
