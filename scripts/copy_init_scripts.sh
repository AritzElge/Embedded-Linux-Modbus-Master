#!/bin/bash

PROJECT_ROOT=$1 # Capture the argument

# --- Path Configuration ---
SCRIPTS_PATH="$PROJECT_ROOT/scripts" 
OVERLAY_PATH="$PROJECT_ROOT/galileo/buildroot/board/intel/galileo/rootfs_overlay/etc/init.d"

# Create detination directory
mkdir -p "$OVERLAY_PATH" || exit 1

# Copy scripts to the destination directory.
# The path in the overlay must mirror the final path in the rootfs.
cp -v "${SCRIPTS_PATH}"/S60mount_hdd "${OVERLAY_PATH}"/S60mount_hdd || exit 1
cp -v "${SCRIPTS_PATH}"/S61error_blink_daemon "${OVERLAY_PATH}"/S61error_blink_daemon || exit 1
cp -v "${SCRIPTS_PATH}"/S71polling_daemon "${OVERLAY_PATH}"/S71polling_daemon || exit 1
cp -v "${SCRIPTS_PATH}"/S72schedule_daemon "${OVERLAY_PATH}"/S72schedule_daemon || exit 1

# VERY IMPORTANT: Ensure execute permissions
chmod +x "${OVERLAY_PATH}"/S60mount_hdd || exit 1
chmod +x "${OVERLAY_PATH}"/S61error_blink_daemon || exit 1
chmod +x "${OVERLAY_PATH}"/S71polling_daemon || exit 1
chmod +x "${OVERLAY_PATH}"/S72schedule_daemon || exit 1

echo "Copy completed."