#!/bin/sh

# start_schedule_daemon.sh
# Runs continuously to manage the schedule without using cron and reports status.

MOUNT_POINT="/mnt/hdd"

# --- DEFINITION OF ABSOLUTE PATHS ---
GET_TIME_SCRIPT="/mnt/hdd/daemons/modbus/get_sleep_time.py"
ACTION_SCRIPT="/mnt/hdd/daemons/modbus/schedule_daemon.py"
# The set_status utility is defined as a helper function below
# --------------------------------------

LOG_DIR="$MOUNT_POINT/logs"
LOG_FILE="$LOG_DIR/schedule_daemon.log"
ERROR_LOG_FILE="$LOG_DIR/schedule_daemon_error.log"
STATUS_FILE="/tmp/status/schedule_daemon.status"
# Use the absolute path for the HDD mount status file
SYSTEM_STATUS_FILE="/tmp/status/system_status.txt" 

# --- Helper Function: Safely write daemon status using flock ---
set_status() {
    mkdir -p /tmp/status/ # Ensure status directory exists
    exec 9>"$STATUS_FILE"
    flock -n 9 || { echo "ERROR: Could not lock daemon status file." >> /dev/kmsg; return 1; }
    printf "%s" "$1" >&9 
    exec 9>&-    
    return 0
}

# Initial status setting
set_status 0 # Assume healthy initially

echo "Starting schedule daemon..." >> /dev/kmsg

while true; do
    # Determine logging location based on HDD status
    # Use grep -qs to quickly check if /mnt/hdd is mounted
    if grep -qs "$MOUNT_POINT" /proc/mounts; then
        # HDD mounted: use persistent storage
        mkdir -p "$LOG_DIR"
        CURRENT_LOG="$LOG_FILE"
        CURRENT_ERROR_LOG="$ERROR_LOG_FILE"
    else
        # HDD NOT mounted: use temporary storage
        echo "WARNING: HDD not mounted for schedule daemon. Logging to /tmp/." >> /dev/kmsg
        CURRENT_LOG="/tmp/schedule_daemon.log"
        CURRENT_ERROR_LOG="/tmp/schedule_daemon_error.log"
        # Read the SYSTEM_STATUS_FILE with its absolute path
        if [ "$(cat "$SYSTEM_STATUS_FILE")" = "10" ]; then
             echo "SYSTEM ERROR: HDD mount failed at boot." >> /dev/kmsg
        fi
    fi

    echo "--- $(date) ---" >> "$CURRENT_LOG"
    
    # 1. Execute the main action (schedule_daemon.py) using absolute path
    python "$ACTION_SCRIPT" >> "$CURRENT_LOG" 2>> "$CURRENT_ERROR_LOG"
    ACTION_EXIT_CODE=$?

    # 2. Get the calculated sleep time using absolute path.
    SLEEP_SECONDS=$(python "$GET_TIME_SCRIPT")
    GET_TIME_EXIT_CODE=$?

    # --- Check for ANY failure in the loop iteration ---
    if [ $ACTION_EXIT_CODE -ne 0 ] || [ $GET_TIME_EXIT_CODE -ne 0 ]; then
        # If either script failed, report the single error code 3 (Schedule Daemon Error)
        echo "ERROR: A schedule script failed (Action Code: $ACTION_EXIT_CODE, GetTime Code: $GET_TIME_EXIT_CODE)." >> /dev/kmsg
        set_status 3 
        
        # Default sleep to avoid tight loop on crash
        SLEEP_SECONDS=300 # Sleep for 5 minutes on error
    else
        # If both steps succeeded, ensure status is OK
        set_status 0 
    fi

    echo "Next execution in $SLEEP_SECONDS seconds." >> "$CURRENT_LOG"

    # 3. Wait for the calculated amount of time
    sleep "$SLEEP_SECONDS"
done

