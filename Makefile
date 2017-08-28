THEOS_DEVICE_IP = 192.168.3.234
TARGET = iphone:latest:8.0
ARCHS = arm64 armv7

include theos/makefiles/common.mk

TWEAK_NAME = AppListUpdater
AppListUpdater_FILES = Tweak.xm AppListUtils.m

include $(THEOS_MAKE_PATH)/tweak.mk


