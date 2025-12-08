#!/bin/sh
# start_polling_daemon.sh
# Runs continuously to manage data polling every 15 minutes and reports its status.

MOUNT_POINT="/mnt/hdd"

# --- DEFINITION OF ABSOLUTE PATHS ---
# We assume this script is in /usr/bin/ in the final image
ACTION_SCRIPT="/mnt/hdd/daemons/modbus/polling_daemon.py"
# ----------------------------------------------------

LOG_DIR="$MOUNT_POINT/logs"
LOG_FILE="$LOG_DIR/modbus.log"
ERROR_LOG_FILE="$LOG_DIR/error.log"
STATUS_FILE="/tmp/status/polling_daemon.status" 
SYSTEM_STATUS_FILE="/tmp/status/system_status.txt" 

# --- Helper Function: Safely write daemon status using flock ---
set_status() {
    mkdir -p /tmp/status/ # Ensure status directory exists
    exec 9>"$STATUS_FILE"
    flock -n 9 || { echo "ERROR: Could not lock daemon status file." >> /dev/kmsg; return 1; }
    echo -n "$1" >&9 
    exec 9>&-    
    return 0
}

# Initial status setting
set_status 0 # Assume healthy initially

# --- Main loop to manage the daemon's lifecycle ---
while true; do

    # --- VERIFY EXISTENCE OF THE PYTHON SCRIPT USING ABSOLUTE PATH ---
    if [ ! -f "$ACTION_SCRIPT" ]; then
        echo "ERROR: polling_daemon.py not found at $ACTION_SCRIPT." >> /dev/kmsg
        set_status 3 # Error Code 3: Daemon script not found/failed to run
        sleep 900 # Sleep 15 minutes before retrying
        continue # Return to the start of the while true loop
    fi
    # --------------------------------------------------------

    # 1. Verify if the HDD is mounted before attempting to log to it
    if grep -qs "$MOUNT_POINT" /proc/mounts; then
        # HDD is mounted. Use full paths for logging.
        mkdir -p "$LOG_DIR"
        python "$ACTION_SCRIPT" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
    else
        # HDD is NOT mounted. Log to temporary storage (/tmp)
        echo "WARNING: HDD not mounted. Logging to /tmp/." >> /dev/kmsg
        if [ "$(cat "$SYSTEM_STATUS_FILE")" = "10" ]; then
             echo "SYSTEM ERROR: HDD mount failed at boot." >> /dev/kmsg
        fi
        python "$ACTION_SCRIPT" >> /tmp/modbus.log 2>> /tmp/error.log
    fi

    # 2. Check the exit code of the Python script
    EXIT_CODE=$?

    if [ $EXIT_CODE -ne 0 ]; then
        echo "ERROR: polling_daemon.py exited with code $EXIT_CODE." >> /dev/kmsg
        set_status 3 # Error Code 3: Daemon process failure
    else 
        set_status 0 # Success: Reset status to OK if the execution was clean
    fi
    
    # 3. Wait 15 minutes before the next execution
    sleep 900
done
