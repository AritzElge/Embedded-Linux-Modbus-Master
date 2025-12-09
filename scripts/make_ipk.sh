#!/bin/bash

# --- Path Configuration ---
# Path to the main Buildroot directory
BUILDROOT_DIR="./galileo/buildroot"
# Path to your external tree (relative to the directory where you run this script)
EXTERNAL_DIR="./src"
# --------------------------

echo "Starting process using absolute paths..."

# Calculate the absolute path of the external directory
# This converts ./src into something like /home/user/project/src
ABSOLUTE_EXTERNAL_PATH="$(pwd)/$EXTERNAL_DIR"

echo "Using absolute path for BR2_EXTERNAL: $ABSOLUTE_EXTERNAL_PATH"

# Navigate into the Buildroot directory
cd "$BUILDROOT_DIR" || exit

# Clean and regenerate the configuration
make clean
# Pass the ABSOLUTE PATH to both make defconfig and make all
make BR2_EXTERNAL="$ABSOLUTE_EXTERNAL_PATH" defconfig

# Compile
make BR2_EXTERNAL="$ABSOLUTE_EXTERNAL_PATH" all

# Return to the original directory
cd -

echo "Process completed successfully."
