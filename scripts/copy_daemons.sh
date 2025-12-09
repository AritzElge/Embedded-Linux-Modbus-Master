#!/bin/bash

# --- Path Configuration ---
DAEMONS_PATH=./src
OVERLAY_USR_BIN_PATH=./galileo/buildroot/board/intel/galileo/rootfs_overlay/usr/bin
OVERLAY_USR_SBIN_PATH=./galileo/buildroot/board/intel/galileo/rootfs_overlay/usr/sbin

# Copy the daemons to the destination directory.
# 1. error_code_blink daemon
echo "[DAEMON_COPY] Copying error_code_blink daemon..."
cp -v $(DAEMONS_PATH)/error_code_blink/error_code_blink $(OVERLAY_USR_SBIN_PATH)/error_code_blink
# Ensure execute permissions:
chmod +x $(OVERLAY_USR_SBIN_PATH)/error_code_blink
# 2. ssh_app
echo "[DAEMON_COPY] Copying ssh_app (not an actual daemon)..."
cp -rv $(DAEMONS_PATH)/ssh_app/* $(OVERLAY_USR_BIN_PATH)/
# Ensure execute permissions:
chmod +x $(OVERLAY_USR_BIN_PATH)/monitor_status.sh
# 3. modbus daemons
echo "[DAEMON_COPY] Copying modbus daemons..."
cp -v $(DAEMONS_PATH)/modbus/* $(OVERLAY_USR_BIN_PATH)/
# Ensure execute permissions:
chmod +x $(OVERLAY_USR_BIN_PATH)/start_polling_daemon.sh
chmod +x $(OVERLAY_USR_BIN_PATH)/start_schedule_daemon.sh

echo "Copy completed."
