include theos/makefiles/common.mk

LIBRARY_NAME = libclassdumpdyld
libclassdumpdyld_FILES = classdumpdyldlib.mm
libclassdumpdyld_LDFLAGS = -lsubstrate
libclassdumpdyld_LDFLAGS += -Wl,-segalign,0x4000
include $(THEOS_MAKE_PATH)/library.mk
