#TARGET = macosx
export ARCHS=armv7 arm64
include theos/makefiles/common.mk

TOOL_NAME = classdump-dyld
classdump-dyld_FILES = main.mm
include theos/makefiles/tool.mk
