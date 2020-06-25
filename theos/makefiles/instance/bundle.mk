ifeq ($(_THEOS_RULES_LOADED),)
include $(THEOS_MAKE_PATH)/rules.mk
endif

.PHONY: internal-bundle-all_ internal-bundle-stage_ internal-bundle-compile

ifeq ($(call __theos_bool,$(or $($(THEOS_CURRENT_INSTANCE)_DYNAMIC_LIBRARY),$(_THEOS_TRUE))),$(_THEOS_TRUE))
_THEOS_INTERNAL_LDFLAGS += -dynamiclib
endif

# Bundle Setup
LOCAL_BUNDLE_NAME = $(or $($(THEOS_CURRENT_INSTANCE)_BUNDLE_NAME),$(THEOS_CURRENT_INSTANCE))
LOCAL_BUNDLE_EXTENSION = $(or $($(THEOS_CURRENT_INSTANCE)_BUNDLE_EXTENSION),bundle)

_LOCAL_BUNDLE_FULL_NAME = $(LOCAL_BUNDLE_NAME).$(LOCAL_BUNDLE_EXTENSION)
_THEOS_SHARED_BUNDLE_BUILD_PATH = $(THEOS_OBJ_DIR)/$(_LOCAL_BUNDLE_FULL_NAME)
_THEOS_SHARED_BUNDLE_STAGE_PATH = $(THEOS_STAGING_DIR)$($(THEOS_CURRENT_INSTANCE)_INSTALL_PATH)/$(_LOCAL_BUNDLE_FULL_NAME)
_LOCAL_INSTANCE_TARGET := $(_LOCAL_BUNDLE_FULL_NAME)$(_THEOS_TARGET_BUNDLE_BINARY_SUBDIRECTORY)/$(THEOS_CURRENT_INSTANCE)$(TARGET_EXE_EXT)
include $(THEOS_MAKE_PATH)/instance/shared/bundle.mk
# End Bundle Setup

ifeq ($(_THEOS_MAKE_PARALLEL_BUILDING), no)
internal-bundle-all_:: $(_OBJ_DIR_STAMPS) shared-instance-bundle-all $(THEOS_OBJ_DIR)/$(_LOCAL_INSTANCE_TARGET)
else
internal-bundle-all_:: $(_OBJ_DIR_STAMPS) shared-instance-bundle-all
	$(ECHO_NOTHING)$(MAKE) -f $(_THEOS_PROJECT_MAKEFILE_NAME) --no-print-directory --no-keep-going \
		internal-bundle-compile \
		_THEOS_CURRENT_TYPE=$(_THEOS_CURRENT_TYPE) THEOS_CURRENT_INSTANCE=$(THEOS_CURRENT_INSTANCE) _THEOS_CURRENT_OPERATION=compile \
		THEOS_BUILD_DIR="$(THEOS_BUILD_DIR)" _THEOS_MAKE_PARALLEL=yes$(ECHO_END)

internal-bundle-compile: $(THEOS_OBJ_DIR)/$(_LOCAL_INSTANCE_TARGET)
endif

ifneq ($(OBJ_FILES_TO_LINK),)

$(eval $(call _THEOS_TEMPLATE_DEFAULT_LINKING_RULE,$(_LOCAL_INSTANCE_TARGET),nowarn))

else # OBJ_FILES_TO_LINK == ""

$(THEOS_OBJ_DIR)/$(_LOCAL_INSTANCE_TARGET):
	$(NOTICE_EMPTY_LINKING)

endif # OBJ_FILES_TO_LINK

internal-bundle-stage_:: shared-instance-bundle-stage

$(eval $(call __mod,instance/bundle.mk))
