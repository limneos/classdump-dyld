GO_EASY_ON_ME=1
#TARGET = simulator:clang:11.0
#TARGET = macosx
TARGET = iphone:clang::6.0
export ARCHS=armv7 arm64
#export ARCHS=x86_64 
include theos/makefiles/common.mk
TOOL_NAME = classdump-dyld
classdump-dyld_FILES = main.xm
classdump-dyld_LDFLAGS = -Wl,-segalign,0x4000
classdump-dyld_CODESIGN_FLAGS = -Sent.plist
include theos/makefiles/tool.mk
include theos/makefiles/library.mk
SUBPROJECTS += classdumpdyldlib
include $(THEOS_MAKE_PATH)/aggregate.mk
