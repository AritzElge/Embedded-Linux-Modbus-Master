#!/bin/bash

# --- Path Configuration ---
PROJECT_ROOT=$1 # Capture argument 1

C_SOURCE_DIR="$PROJECT_ROOT/src/error_code_blink/"
TOOLCHAIN_BIN_DIR="$BUILDROOT_DIR/output/host/bin"

echo "[C_BUILD] Starting C daemon compilation (using internal Makefile paths)..."

# 1. Compile error_code_blink program
cd "$C_SOURCE_DIR" || { echo "[C_BUILD] Error: C source directory not found."; exit 1; }
echo "[C_BUILD] Running local make all..."
make clean
make all

if [ $? -eq 0 ]; then
    echo "[C_BUILD] C Daemon compilation finished successfully."
else
    echo "[C_BUILD] Error: C Daemon compilation failed."
    exit 1
fi

exit 0
