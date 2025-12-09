#!/bin/bash

# --- Path Configuration ---
DAEMONS_PATH=./src

echo "[C_BUILD] Starting C daemon compilation (using internal Makefile paths)..."

# Move to Daemons root directory
cd "$(DAEMONS_PATH)" || { echo "[C_BUILD] Error: Daemons root directory not found."; exit 1; }

# 1. Compile error_code_blink program
cd error_supervisor_c || { echo "[C_BUILD] Error: C source directory not found."; exit 1; }
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
