# Include the Makefiles of packages we will create later
include $(sort $(wildcard $(BR2_EXTERNAL_MY_EXTERNAL_PROJECT_PATH)/package/*/*.mk))
