ifeq ($(_THEOS_TARGET_LOADED),)
_THEOS_TARGET_LOADED := 1
THEOS_TARGET_NAME := iphone

_THEOS_TARGET_CC := clang
_THEOS_TARGET_CXX := clang++
_THEOS_TARGET_ARG_ORDER := 1 2
ifeq ($(__THEOS_TARGET_ARG_1),clang)
_THEOS_TARGET_ARG_ORDER := 2 3
else ifeq ($(__THEOS_TARGET_ARG_1),gcc)
_THEOS_TARGET_ARG_ORDER := 2 3
endif

# A version specified as a target argument overrides all previous definitions.
_SDKVERSION := $(or $(__THEOS_TARGET_ARG_$(word 1,$(_THEOS_TARGET_ARG_ORDER))),$(SDKVERSION_$(THEOS_CURRENT_ARCH)),$(SDKVERSION))
_THEOS_TARGET_SDK_VERSION := $(or $(_SDKVERSION),latest)
_THEOS_TARGET_INCLUDE_SDK_VERSION := $(or $(INCLUDE_SDKVERSION),$(INCLUDE_SDKVERSION_$(THEOS_CURRENT_ARCH)),latest)

_SDK_DIR := $(THEOS)/sdks
_IOS_SDKS := $(sort $(patsubst $(_SDK_DIR)/iPhoneOS%.sdk,%,$(wildcard $(_SDK_DIR)/iPhoneOS*.sdk)))
ifeq ($(words $(_IOS_SDKS)),0)
before-all::
	@$(PRINT_FORMAT_ERROR) "You do not have an SDK in $(_SDK_DIR)." >&2; exit 1
endif
_LATEST_SDK := $(lastword $(_IOS_SDKS))

ifeq ($(_THEOS_TARGET_SDK_VERSION),latest)
override _THEOS_TARGET_SDK_VERSION := $(_LATEST_SDK)
endif

ifeq ($(_THEOS_TARGET_INCLUDE_SDK_VERSION),latest)
override _THEOS_TARGET_INCLUDE_SDK_VERSION := $(_LATEST_SDK)
endif

# We have to figure out the target version here, as we need it in the calculation of the deployment version.
_TARGET_VERSION_GE_8_4 = $(call __simplify,_TARGET_VERSION_GE_8_4,$(shell $(THEOS_BIN_PATH)/vercmp.pl $(_THEOS_TARGET_SDK_VERSION) ge 8.4))
_TARGET_VERSION_GE_7_0 = $(call __simplify,_TARGET_VERSION_GE_7_0,$(shell $(THEOS_BIN_PATH)/vercmp.pl $(_THEOS_TARGET_SDK_VERSION) ge 7.0))
_TARGET_VERSION_GE_6_0 = $(call __simplify,_TARGET_VERSION_GE_6_0,$(shell $(THEOS_BIN_PATH)/vercmp.pl $(_THEOS_TARGET_SDK_VERSION) ge 6.0))
_TARGET_VERSION_GE_4_0 = $(call __simplify,_TARGET_VERSION_GE_4_0,$(shell $(THEOS_BIN_PATH)/vercmp.pl $(_THEOS_TARGET_SDK_VERSION) ge 4.0))
_TARGET_VERSION_GE_3_0 = $(call __simplify,_TARGET_VERSION_GE_3_0,$(shell $(THEOS_BIN_PATH)/vercmp.pl $(_THEOS_TARGET_SDK_VERSION) ge 3.0))

ifeq ($(_TARGET_VERSION_GE_7_0),1)
_THEOS_TARGET_DEFAULT_IPHONEOS_DEPLOYMENT_VERSION := 5.0
else
ifeq ($(_TARGET_VERSION_GE_6_0),1)
_THEOS_TARGET_DEFAULT_IPHONEOS_DEPLOYMENT_VERSION := 4.3
else
_THEOS_TARGET_DEFAULT_IPHONEOS_DEPLOYMENT_VERSION := 3.0
endif
endif

_THEOS_TARGET_IPHONEOS_DEPLOYMENT_VERSION := $(or $(__THEOS_TARGET_ARG_$(word 2,$(_THEOS_TARGET_ARG_ORDER))),$(TARGET_IPHONEOS_DEPLOYMENT_VERSION_$(THEOS_CURRENT_ARCH)),$(TARGET_IPHONEOS_DEPLOYMENT_VERSION),$(_SDKVERSION),$(_THEOS_TARGET_DEFAULT_IPHONEOS_DEPLOYMENT_VERSION))

ifeq ($(_THEOS_TARGET_IPHONEOS_DEPLOYMENT_VERSION),latest)
override _THEOS_TARGET_IPHONEOS_DEPLOYMENT_VERSION := $(_LATEST_SDK)
endif

_DEPLOY_VERSION_GE_5_0 = $(call __simplify,_DEPLOY_VERSION_GE_5_0,$(shell $(THEOS_BIN_PATH)/vercmp.pl $(_THEOS_TARGET_IPHONEOS_DEPLOYMENT_VERSION) ge 5.0))
_DEPLOY_VERSION_GE_3_0 = $(call __simplify,_DEPLOY_VERSION_GE_3_0,$(shell $(THEOS_BIN_PATH)/vercmp.pl $(_THEOS_TARGET_IPHONEOS_DEPLOYMENT_VERSION) ge 3.0))
_DEPLOY_VERSION_LT_4_3 = $(call __simplify,_DEPLOY_VERSION_LT_4_3,$(shell $(THEOS_BIN_PATH)/vercmp.pl $(_THEOS_TARGET_IPHONEOS_DEPLOYMENT_VERSION) lt 4.3))

ifeq ($(_TARGET_VERSION_GE_6_0)$(_DEPLOY_VERSION_GE_3_0)$(_DEPLOY_VERSION_LT_4_3),111)
ifeq ($(ARCHS)$(IPHONE_ARCHS)$(_THEOS_TARGET_WARNED_DEPLOY),)
before-all::
	@$(PRINT_FORMAT_WARNING) "Deploying to iOS 3.0 while building for 6.0 will generate armv7-only binaries." >&2
export _THEOS_TARGET_WARNED_DEPLOY := 1
endif
endif

SYSROOT ?= $(_SDK_DIR)/iPhoneOS$(_THEOS_TARGET_SDK_VERSION).sdk

ifeq ($(SYSROOT),)
SYSROOT ?= $(_SDK_DIR)/iPhoneOS$(_THEOS_TARGET_SDK_VERSION).sdk
ISYSROOT ?= $(_SDK_DIR)/iPhoneOS$(_THEOS_TARGET_INCLUDE_SDK_VERSION).sdk
else
ISYSROOT ?= $(SYSROOT)
endif

TARGET_CC ?= $(_THEOS_TARGET_CC)
TARGET_CXX ?= $(_THEOS_TARGET_CXX)
TARGET_LD ?= $(_THEOS_TARGET_CXX)
TARGET_STRIP ?= strip
TARGET_STRIP_FLAGS ?= -x
TARGET_CODESIGN_ALLOCATE ?= codesign_allocate
TARGET_CODESIGN ?= ldid
TARGET_CODESIGN_FLAGS ?= -S

TARGET_PRIVATE_FRAMEWORK_PATH = $(SYSROOT)/System/Library/PrivateFrameworks
TARGET_PRIVATE_FRAMEWORK_INCLUDE_PATH = $(ISYSROOT)/System/Library/PrivateFrameworks

include $(THEOS_MAKE_PATH)/targets/_common/darwin.mk
include $(THEOS_MAKE_PATH)/targets/_common/darwin_flat_bundle.mk

ifeq ($(_TARGET_VERSION_GE_7_0),1) # >= 7.0 {
	ARCHS ?= armv7 arm64
else # } < 7.0 {
ifeq ($(_TARGET_VERSION_GE_6_0),1) # >= 6.0 {
ifeq ($(_TARGET_VERSION_GE_7_0)$(_DEPLOY_VERSION_GE_5_0),11) # >= 7.0, Deploy >= 5.0 {
	ARCHS ?= armv7 arm64
else # } else {
	ARCHS ?= armv7
endif # }
else # } < 6.0 {
ifeq ($(_TARGET_VERSION_GE_3_0),1) # >= 3.0 {
	ARCHS ?= armv6 armv7
else # } < 3.0 {
	ARCHS ?= armv6
endif # }
endif # }
endif # }
NEUTRAL_ARCH = armv7

ifeq ($(_TARGET_VERSION_GE_8_4),1)
MODULESFLAGS := -fmodules -fcxx-modules -fmodule-name=$(THEOS_CURRENT_INSTANCE) -fbuild-session-file=$(_THEOS_BUILD_SESSION_FILE) -fmodules-prune-after=345600 -fmodules-prune-interval=86400 -fmodules-validate-once-per-build-session
else
MODULESFLAGS :=
endif

# “iOS 9 changed the 32-bit pagesize on 64-bit CPUs from 4096 bytes to 16384:
# all 32-bit binaries must now be compiled with -Wl,-segalign,4000.”
# https://twitter.com/saurik/status/654198997024796672

ifeq ($(THEOS_CURRENT_ARCH),arm64)
LEGACYFLAGS :=
else
LEGACYFLAGS := -Wl,-segalign,4000
endif

SDKFLAGS := -D__IPHONE_OS_VERSION_MIN_REQUIRED=__IPHONE_$(subst .,_,$(_THEOS_TARGET_IPHONEOS_DEPLOYMENT_VERSION))
VERSIONFLAGS := -miphoneos-version-min=$(_THEOS_TARGET_IPHONEOS_DEPLOYMENT_VERSION)

_THEOS_TARGET_CFLAGS := -isysroot "$(ISYSROOT)" $(SDKFLAGS) $(VERSIONFLAGS) $(_THEOS_TARGET_CC_CFLAGS) $(MODULESFLAGS)
_THEOS_TARGET_LDFLAGS := -isysroot "$(SYSROOT)" $(SDKFLAGS) $(VERSIONFLAGS) $(LEGACYFLAGS) -multiply_defined suppress

TARGET_INSTALL_REMOTE := $(_THEOS_FALSE)
ifeq ($(call __theos_bool,$(THEOS_INSTALL_USING_SSH)),$(_THEOS_TRUE))
	TARGET_INSTALL_REMOTE := $(_THEOS_TRUE)
endif
_THEOS_TARGET_DEFAULT_PACKAGE_FORMAT := deb
endif
