#!/bin/sh
# start_polling_daemon.sh
# Runs continuously to manage the schedule without using cron.

LOG_FILE="/tmp/modbus.log"
ERROR_LOG_FILE="/tmp/error.log"

while true; do

    # 1. Main action execution
    python polling_daemon.py >> $LOG_FILE 2> $ERROR_LOG_FILE

    # 2. Wait fixed 15 minutes
    sleep 900
done
