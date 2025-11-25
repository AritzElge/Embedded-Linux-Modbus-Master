#!/bin/bash

echo "Installing Host dependencies for Buildroot"

# Initialize the error flag: 0 = success; 1 = failure
INSTALL_FAILED=0

# Check if the user has root privileges to run apt install
if [ "$(id -u)" != "0" ]; then
	echo "[WARNING] This script needs root privileges to install packages!"
	echo "[WARNING] Please run this script with 'sudo ./install_dependencies.sh"
	INSTALL_FAILED=1
	exit $INSTALL_FAILED
fi

echo "[INFO] Updating package list..."
sudo apt update

# Install the dependencies
sudo apt install -y build-essential libncurses5-dev libncursesw5-dev flex bison libssl-dev libelf-dev git

INSTALL_FAILED=$?

if [ $INSTALL_FAILED -eq 0 ]; then
	echo "[INFO] All dependencies installed successfully."
else
	echo "[WARNING] Dependency installation completed with errors"
	echo "[WARNING] Please review the output for failed packages"
fi

# Exit with the flag value (0 for success, 1 for failure)

exit $INSTALL_FAILED
