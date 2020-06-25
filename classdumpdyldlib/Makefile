GO_EASY_ON_ME=1
TARGET = appletv 
export ARCHS= arm64
export SDKVERSION=12.41
include theos/makefiles/common.mk

LIBRARY_NAME = libclassdumpdyld
libclassdumpdyld_FILES = classdumpdyldlib.xm
libclassdumpdyld_LIBRARIES = substrate
#libclassdumpdyld_LDFLAGS = -lsubstrate
libclassdumpdyld_LDFLAGS += -F. -F.. -undefined dynamic_lookup
libclassdumpdyld_CFLAGS += -fno-objc-arc -ggdb
include $(THEOS_MAKE_PATH)/library.mk

#after-libclassdumpdyld-stage::
 # $(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/usr/lib/cycript0.9/net/limneos$(ECHO_END)
  #$(ECHO_NOTHING)cp classdumpdyld.cy $(THEOS_STAGING_DIR)/usr/lib/cycript0.9/net/limneos$(ECHO_END)
