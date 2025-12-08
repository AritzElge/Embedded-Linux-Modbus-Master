# package/ELI_galileo/ELI_galileo.mk

# Package Name and Version
ELI_GALILEO_VERSION = 1.0.0
# Define the local source location
ELI_GALILEO_SITE = $(BR2_EXTERNAL_MY_EXTERNAL_PROJECT_PATH)/src_extern
ELI_GALILEO_SITE_METHOD = local

# ------------------------------------------------------------------
# C Code Compilation (blink_error_code)
# ------------------------------------------------------------------
# Tell Buildroot to enter this subdirectory to run 'make'
ELI_GALILEO_SUBDIR = error_supervisor_c

# Define how to build the C binary using your existing Makefile and the cross-compiler
define ELI_GALILEO_BUILD_CMDS
    # CC/LD are Buildroot's cross-compilers; $(@D) is the current build dir
    $(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D) all
endef

# ------------------------------------------------------------------
# Final Installation Rules (to the TARGET_DIR which becomes the rootfs /)
# ------------------------------------------------------------------
define ELI_GALILEO_INSTALL_TARGET_CMDS
    # Install the compiled C binary to /usr/sbin/
    # The binary is created in the ELI_GALILEO_SUBDIR during the build step
    $(INSTALL) -m 0755 $(@D)/blink_error_code $(TARGET_DIR)/usr/sbin/blink_error_code

    # Install scripts (.sh and .py) from modbus/src to /usr/bin/ (executable permissions 0755)
    $(INSTALL) -m 0755 $(BR2_EXTERNAL_MY_EXTERNAL_PROJECT_PATH)/src_externos/modbus/src/*.sh $(TARGET_DIR)/usr/bin/
    $(INSTALL) -m 0755 $(BR2_EXTERNAL_MY_EXTERNAL_PROJECT_PATH)/src_externos/modbus/src/*.py $(TARGET_DIR)/usr/bin/

    # Install .json data files from modbus/src to /etc/ (data permissions 0644)
    $(INSTALL) -m 0644 $(BR2_EXTERNAL_MY_EXTERNAL_PROJECT_PATH)/src_externos/modbus/src/*.json $(TARGET_DIR)/etc/

    # Install the ssh_app/monitor_status.sh script to /usr/bin/
    $(INSTALL) -m 0755 $(BR2_EXTERNAL_MY_EXTERNAL_PROJECT_PATH)/src_externos/ssh_app/monitor_status.sh $(TARGET_DIR)/usr/bin/
endef

# Magic line to register the package with Buildroot
$(eval $(generic-package))
