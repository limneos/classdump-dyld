DEBUG=yes
debug=yes
export debug=yes
export DEBUG=yes
GO_EASY_ON_ME=1
TARGET = appletv
export ARCHS= arm64
export SDKVERSION=12.4
include theos/makefiles/common.mk
THEOS_DEVICE_IP=guest-room.local
TOOL_NAME = classdump-dyld
classdump-dyld_FILES = main.xm JRSwizzle.m
classdump-dyld_LIBRARIES = substrate
classdump-dyld_FRAMEWORKS = FrontBoard
#classdump-dyld_FRAMEWORKS = SpringBoardUI
classdump-dyld_CODESIGN_FLAGS=-Sent.plist
classdump-dyld_LDFLAGS = -F. -undefined dynamic_lookup
classdump_dyld_CFLAGS += -fno-objc-arc -ggdb
include theos/makefiles/tool.mk
include theos/makefiles/library.mk
SUBPROJECTS += classdumpdyldlib
include $(THEOS_MAKE_PATH)/aggregate.mk
