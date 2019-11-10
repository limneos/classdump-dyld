GO_EASY_ON_ME=1
#TARGET = simulator:clang:11.0
#TARGET = iphone:clang::6.0
export TARGET = iphone:clang:11.2:9.3
export ARCHS = armv7 arm64 arm64e
include $(THEOS_MAKE_PATH)/common.mk
#export ARCHS = x86_64
LIBRARY_NAME = libclassdumpdyld
libclassdumpdyld_FILES = classdumpdyldlib.xm
#libclassdumpdyld_LDFLAGS= -lsubstrate
libclassdumpdyld_LDFLAGS+= -Wl,-segalign,0x4000
include $(THEOS_MAKE_PATH)/library.mk

after-libclassdumpdyld-stage::
	
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/usr/lib/cycript0.9/net/limneos$(ECHO_END)
 	
	$(ECHO_NOTHING)cp classdumpdyld.cy $(THEOS_STAGING_DIR)/usr/lib/cycript0.9/net/limneos$(ECHO_END)
