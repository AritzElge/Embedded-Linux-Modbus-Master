#!/bin/sh
# start_schedule_daemon.sh
# Runs continuously to manage the schedule without using cron.

GET_TIME_SCRIPT="./get_sleep_time.py"
ACTION_SCRIPT="./schedule_daemon.py"
LOG_FILE="/tmp/schedule_daemon.log"
ERROR_LOG_FILE="/tmp/schedule_daemon_error.log"

echo "Starting schedule daemon..." >> $LOG_FILE

while true; do
    echo "--- $(date) ---" >> $LOG_FILE
    
    # 1. Execute the main action (device_controller.py)
    # This locks schedule_app.lock, then releases it.
    python $ACTION_SCRIPT >> $LOG_FILE 2> $ERROR_LOG_FILE

    # 2. Get the calculated sleep time.
    # This script waits for schedule_app.lock to be free (which it will be).
    SLEEP_SECONDS=$(python $GET_TIME_SCRIPT)
    
    echo "Next execution in $SLEEP_SECONDS seconds." >> $LOG_FILE

    # 3. Wait for the calculated amount of time
    sleep "$SLEEP_SECONDS"
done
