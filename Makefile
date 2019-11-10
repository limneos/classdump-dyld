DEBUG=0
GO_EASY_ON_ME=1
#TARGET = simulator:clang:11.0
#TARGET = macosx
#TARGET = iphone:clang::6.0
export TARGET = iphone:clang:11.2:9.3
export ARCHS=armv7 arm64 arm64e
#export ARCHS=x86_64 
include $(THEOS_MAKE_PATH)/common.mk
TOOL_NAME = classdump-dyld
classdump-dyld_FILES = main.xm
classdump-dyld_LDFLAGS = -Wl,-segalign,0x4000
classdump-dyld_CODESIGN_FLAGS = -Sent.plist
include theos/makefiles/tool.mk
include theos/makefiles/library.mk
SUBPROJECTS += classdumpdyldlib
include $(THEOS_MAKE_PATH)/aggregate.mk
