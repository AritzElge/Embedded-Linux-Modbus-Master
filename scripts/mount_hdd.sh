#!/bin/sh

# mount_hdd.sh: Mounts the external HDD using a fixed device name.

MOUNT_POINT="/mnt/hdd"
# CONFIRM THIS IS YOUR DEVICE NAME IN THE GALILEO (usually sda1)
DEVICE_NAME="/dev/sda1"
STATUS_FILE="/tmp/system_status.txt"

# --- Helper Function: Safely write system status using flock ---
set_status() {
    exec 9>"$STATUS_FILE"
    flock -n 9 || { echo "ERROR: Could not lock status file." >> /dev/kmsg; return 1; }
    echo -n "$1" >&9 
    exec 9>&-    
    return 0
}

# --- 1. Check if the mount point exists ---
if [ ! -d "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
    echo "Created mount point $MOUNT_POINT" >> /dev/kmsg
fi

# --- 2. Mount by fixed device name ---
mount "$DEVICE_NAME" "$MOUNT_POINT"

if [ $? -eq 0 ]; then
    echo "Successfully mounted $DEVICE_NAME on $MOUNT_POINT" >> /dev/kmsg
    set_status 0 # Success: Set OK status
else
    echo "ERROR: Failed to mount the device $DEVICE_NAME." >> /dev/kmsg
    set_status 1 # Error: Set error code 1 (HDD mount failure)
fi

# --- 3. Create expected directories if the mount was successful ---
if [ $? -eq 0 ] && [ -d "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT/logs"
    mkdir -p "$MOUNT_POINT/daemons"
    touch "$STATUS_FILE"
fi
