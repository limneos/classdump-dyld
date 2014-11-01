#TARGET = macosx
export ARCHS=armv7 arm64
include theos/makefiles/common.mk

TOOL_NAME = classdump-dyld
classdump-dyld_FILES = main.xm
include theos/makefiles/tool.mk
include theos/makefiles/library.mk
SUBPROJECTS += classdumpdyldlib
include $(THEOS_MAKE_PATH)/aggregate.mk
