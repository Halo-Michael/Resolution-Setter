export TARGET=iphone:clang::9.0
export ARCHS=armv7 arm64 arm64e
export DEBUG=0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = resolution

$(TOOL_NAME)_FILES = resolution.m
$(TOOL_NAME)_CFLAGS = -fobjc-arc
$(TOOL_NAME)_CODESIGN_FLAGS = -S../entitlements.xml

include $(THEOS_MAKE_PATH)/tool.mk
