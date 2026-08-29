TARGET := iphone:clang:latest:15.0
ARCHS := arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StatusBar16Padding

StatusBar16Padding_FILES = Tweak.x
StatusBar16Padding_CFLAGS = -fobjc-arc -Wno-error -Wno-incompatible-pointer-types

include $(THEOS_MAKE_PATH)/tweak.mk
