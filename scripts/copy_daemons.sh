#!/bin/bash

PROJECT_ROOT=$1 # Capture the argument

# --- Path Configuration (Use absolute paths) ---
DAEMONS_PATH="$PROJECT_ROOT/src"
OVERLAY_USR_BIN_PATH="$PROJECT_ROOT/galileo/buildroot/board/intel/galileo/rootfs_overlay/usr/bin"
OVERLAY_USR_SBIN_PATH="$PROJECT_ROOT/galileo/buildroot/board/intel/galileo/rootfs_overlay/usr/sbin"

mkdir -p "$OVERLAY_USR_BIN_PATH" || exit 1
mkdir -p "$OVERLAY_USR_SBIN_PATH" || exit 1

# Copy the daemons to the destination directory.
# 1. error_code_blink daemon
echo "[DAEMON_COPY] Copying error_code_blink daemon..."
cp -v "${DAEMONS_PATH}"/error_code_blink/error_code_blink "${OVERLAY_USR_SBIN_PATH}"/error_code_blink || exit 1
# Ensure execute permissions:
chmod +x "${OVERLAY_USR_SBIN_PATH}"/error_code_blink || exit 1
# 2. ssh_app
echo "[DAEMON_COPY] Copying ssh_app (not an actual daemon)..."
cp -rv "${DAEMONS_PATH}"/ssh_app/* "${OVERLAY_USR_BIN_PATH}"/ || exit 1
# Ensure execute permissions:
chmod +x "${OVERLAY_USR_BIN_PATH}"/monitor_status.sh || exit 1
# 3. modbus daemons
echo "[DAEMON_COPY] Copying modbus daemons..."
cp -rv "${DAEMONS_PATH}"/modbus/src/* "${OVERLAY_USR_BIN_PATH}"/ || exit 1
# Ensure execute permissions:
chmod +x "${OVERLAY_USR_BIN_PATH}"/start_polling_daemon.sh || exit 1
chmod +x "${OVERLAY_USR_BIN_PATH}"/start_schedule_daemon.sh || exit 1
# Get the modules for pip to install
echo "[DAEMON_COPY] Downloading Python wheels to cache..."
mkdir -p "${OVERLAY_USR_BIN_PATH}"/python_packages || exit 1
pip download filelock=3.8.0 six=1.17.0 pyserial=3.5 pymodbus=2.5.3 --dest "${OVERLAY_USR_BIN_PATH}"/python_packages

echo "Copy completed."
