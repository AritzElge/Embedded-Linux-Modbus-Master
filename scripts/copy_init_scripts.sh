#!/bin/bash

PROJECT_ROOT=$1 # Capture the argument

# --- Path Configuration ---
SCRIPTS_PATH="$PROJECT_ROOT/scripts" 
OVERLAY_PATH="$PROJECT_ROOT/galileo/buildroot/board/intel/galileo/rootfs_overlay/etc/init.d"

# Copy scripts to the destination directory.
# The path in the overlay must mirror the final path in the rootfs.
cp -v $(SCRIPTS_PATH)/s60mount_hdd $(OVERLAY_PATH)/etc/init.d/s60mount_hdd
cp -v $(SCRIPTS_PATH)/s61error_blink_daemon $(OVERLAY_PATH)/etc/init.d/s61error_blink_daemon
cp -v $(SCRIPTS_PATH)/s71polling_daemon $(OVERLAY_PATH)/etc/init.d/s71polling_daemon
cp -v $(SCRIPTS_PATH)/s72schedule_daemon $(OVERLAY_PATH)/etc/init.d/s72schedule_daemon

# VERY IMPORTANT: Ensure execute permissions
chmod +x $(OVERLAY_PATH)/etc/init.d/s60mount_hdd
chmod +x $(OVERLAY_PATH)/etc/init.d/s61error_blink_daemon
chmod +x $(OVERLAY_PATH)/etc/init.d/s71polling_daemon
chmod +x $(OVERLAY_PATH)/etc/init.d/s72schedule_daemon

echo "Copy completed."