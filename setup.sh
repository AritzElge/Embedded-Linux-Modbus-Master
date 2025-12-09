#!/bin/bash

# --- Script Configuration ---
BUILDROOT_VERSION=2019.02
REPO_URL="git://git.buildroot.net/buildroot.git"
# Define the project root as an absolute, immutable path
PROJECT_ROOT=$(pwd) 

# Define absolute paths for robustness
BUILDROOT_DIR="$PROJECT_ROOT/galileo/buildroot"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
SRC_DIR="$PROJECT_ROOT/src"

echo "[INFO] Starting setup script from $PROJECT_ROOT"

# Install Buildroot dependencies (assuming this script is robust)
sudo "$SCRIPTS_DIR/install_dependencies.sh"
EXIT_STATUS=$?

if [ $EXIT_STATUS -ne 0 ]; then
    echo "[ERROR] Dependency installation failed. Exiting."
    exit 1
fi
echo "[INFO] Dependency installation finished successfully."

# -- Step 1 & 2: Clone/Update repository and checkout version --
mkdir -p "$BUILDROOT_DIR"
cd "$BUILDROOT_DIR" || exit 1

if [ ! -d ".git" ]; then
    echo "[INFO] Cloning repository into $BUILDROOT_DIR..."
    git clone "$REPO_URL" . || exit 1
else
    echo "[INFO] Repository already cloned. Updating and checking out version..."
fi

echo "[INFO] Switching to version: $BUILDROOT_VERSION"
git checkout "${BUILDROOT_VERSION}" || exit 1
echo "Buildroot repository ready at $BUILDROOT_DIR"

# --- Project Configuration and Compilation ---

# Return to the project root to run the scripts
cd "$PROJECT_ROOT"

echo "Copying init.d Scripts to overlay..."
# Pass PROJECT_ROOT to the script so it uses absolute paths internally
"$SCRIPTS_DIR/copy_init_scripts.sh" "$PROJECT_ROOT"

echo "Copying .config to buildroot directory..."
cp "./.config" "$BUILDROOT_DIR/.config"

echo "STEP 1: Compiling buildroot for C and C++ toolchain generation..."
cd "$BUILDROOT_DIR"
make -j$(($(nproc) - 1))
cd "$PROJECT_ROOT"

echo "STEP 2: Compiling C daemons..."
# Pass PROJECT_ROOT and BUILDROOT_DIR to the C compilation script
"$SCRIPTS_DIR/compile_daemons.sh" "$PROJECT_ROOT" "$BUILDROOT_DIR"

echo "STEP 3: Copying daemons to overlay..."
# Pass PROJECT_ROOT to the daemon copy script
"$SCRIPTS_DIR/copy_daemons.sh" "$PROJECT_ROOT"

echo "STEP 4: Final Buildroot compilation..."
cd "$BUILDROOT_DIR"
make -j$(($(nproc) - 1)) all
cd "$PROJECT_ROOT"

echo "Build process finished successfully."
exit 0
