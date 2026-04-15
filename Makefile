TARGET := iphone:clang:latest:14.0
ARCHS = arm64
INSTALL_TARGET_PROCESSES = YouTube
THEOS_PACKAGE_SCHEME = rootless
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTClassicDarkTheme

$(TWEAK_NAME)_FILES = Tweak.x Settings.x YTCDTPrefs.m
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_CFLAGS += -DPACKAGE_VERSION='@"$(shell grep '^Version:' control | cut -d' ' -f2)"'

include $(THEOS_MAKE_PATH)/tweak.mk
