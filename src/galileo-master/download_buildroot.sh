#!/bin/bash

# --- Script Configuration ---
BUIDLROOT_VERSION=2019.02
REPO_URL="git://git.buildroot.net/buildroot.git"

# Install Buildroot dependencies

sudo ./install_dependencies.sh
EXIT_STATUS=$?

# Controll return from script
if [ $EXIT_STATUS -ne 0 ]; then
	echo "[ERROR] The dependency installation script failed (Exit Status: 1)"
	echo "[ERROR] Cannot proceed with Buildroot setup. Exiting"
	exit 1
fi

echo "[INFO] Dependency installation finished successfully. Proceeding with Buildroot setup."

# Change directory to ensure the scripts runs from the galileo-master/ root
cd "$(dirname "$0")" || exit 1

echo " Starting Buildroot download for Galileo Gen 2"

# -- Step1: Clone the Buildroot repository --
if [ ! -d ".git" ]; then
	echo "[INFO] .git directory not found. Cloning repository..."
	if git clone "$REPO_URL"; then
		echo "[INFO] Cloning completed successfully."
	else
		echo "[ERROR] Failed during repository cloning. Exiting."
		exit 1
	fi
else
	echo "[INFO] Repository already cloned. Skipping cloning step"
fi

# -- Step 2: Switch to the specific version (tag) --
echo "[INFO] Switching to the specific version (tag): 2019.02"
cd buildroot || exit 1
if git checkout "${BUIDLROOT_VERSION}"; then
	echo "[INFO] Checkout completed successfully. version 2019.02 selected."
else
	echo "[ERROR] Failed to checkout version 2019.02, Exiting."
	exit 1
fi

echo "Buildroot configuration complete."
echo "Now, run 'make galileo_defconfig' , 'make menuconfig', 'make linux-menuconfig' and 'make' in the 'buildroot/' directory."

exit 0
