# ====================================================================
# Makefile for Intel Galileo Gen 2 HAL project with Buildroot
# ====================================================================

# Define Buildroot path relative to this folder
BUILDROOT_DIR ?= ../../galileo/buildroot

# Define the path to your cross-compiler.
# The 'shell find ...' command automatically locates the compiler within the Buildroot output path.
# Assumes buildroot folder is located one directory level up (../buildroot).
CROSS_COMPILE := $(shell find $(BUILDROOT_DIR)/output/host/bin -name "*i586-linux-gcc" | head -n 1)

# Define the root path of the Buildroot output
BUILDROOT_OUTPUT ?= $(BUILDROOT_DIR)/output

# Define the staging directory where mraa headers and libs are installed
STAGING_DIR := $(BUILDROOT_OUTPUT)/host/i586-buildroot-linux-uclibc/sysroot

# Add the include path for mraa headers (-I...)
# Add the library path for mraa library file (-L...)
MRAA_FLAGS := -I$(STAGING_DIR)/usr/include -L$(STAGING_DIR)/usr/lib

# Linker Flags (LDFLAGS): 
# Add -lmraa to link against the mraa library
LDFLAGS := -lmraa

# Compiler Flags (CFLAGS):
# -Wall and -Wextra enable useful warnings.
# -std=c99 specifies the C99 standard.
# -O2 optimizes the code.
# -D_POSIX_C_SOURCE=200809L enables necessary POSIX definitions (like O_CLOEXEC and usleep).
CFLAGS := -Wall -Wextra -std=c99 -O2 -D_POSIX_C_SOURCE=200809L

# Define the source files (.c) to be compiled
SRCS := $(wildcard src/*.c)

# Define the name of the final executable target
TARGET := error_code_blink

# --------------------------------------------------
# Build Rules 
# --------------------------------------------------

# The 'all' rule is the default and builds the final target
all: $(TARGET)

# Rule to build the executable from the source files
$(TARGET): $(SRCS)
	@echo "----------------------------------------------------"
	@echo "Cross-Compiling '$(TARGET)' using:"
	@echo $(CROSS_COMPILE)
	@echo "----------------------------------------------------"
	$(CROSS_COMPILE) $(CFLAGS) $^ -o $@ $(LDFLAGS)

# Rule to clean up generated files (run 'make clean')
clean:
	@echo "Cleaning build artifacts..."
	rm -f $(TARGET) *.o

.PHONY: all clean

