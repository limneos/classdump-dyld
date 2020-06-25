ifeq ($(_THEOS_RULES_LOADED),)
include $(THEOS_MAKE_PATH)/rules.mk
endif

.PHONY: internal-framework-all_ internal-framework-stage_ internal-framework-compile


# Bundle Setup
LOCAL_INSTALL_PATH ?= $(or $(strip $($(THEOS_CURRENT_INSTANCE)_INSTALL_PATH)),/Library/Frameworks)
LOCAL_BUNDLE_NAME = $(or $($(THEOS_CURRENT_INSTANCE)_BUNDLE_NAME),$($(THEOS_CURRENT_INSTANCE)_FRAMEWORK_NAME),$(THEOS_CURRENT_INSTANCE))

_LOCAL_BUNDLE_FULL_NAME = $(LOCAL_BUNDLE_NAME).framework
_THEOS_SHARED_BUNDLE_BUILD_PATH = $(THEOS_OBJ_DIR)/$(_LOCAL_BUNDLE_FULL_NAME)
_THEOS_SHARED_BUNDLE_STAGE_PATH = $(THEOS_STAGING_DIR)$(LOCAL_INSTALL_PATH)/$(_LOCAL_BUNDLE_FULL_NAME)
_LOCAL_INSTANCE_TARGET := $(_LOCAL_BUNDLE_FULL_NAME)$(_THEOS_TARGET_BUNDLE_BINARY_SUBDIRECTORY)/$(THEOS_CURRENT_INSTANCE)
include $(THEOS_MAKE_PATH)/instance/shared/bundle.mk
# End Bundle Setup

_THEOS_INTERNAL_LDFLAGS += -dynamiclib -install_name "$(LOCAL_INSTALL_PATH)/$(_LOCAL_INSTANCE_TARGET)"

ifeq ($(_THEOS_MAKE_PARALLEL_BUILDING), no)
internal-framework-all_:: $(_OBJ_DIR_STAMPS) shared-instance-bundle-all $(THEOS_OBJ_DIR)/$(_LOCAL_INSTANCE_TARGET)
else
internal-framework-all_:: $(_OBJ_DIR_STAMPS) shared-instance-bundle-all
	$(ECHO_NOTHING)$(MAKE) -f $(_THEOS_PROJECT_MAKEFILE_NAME) --no-print-directory --no-keep-going \
		internal-framework-compile \
		_THEOS_CURRENT_TYPE=$(_THEOS_CURRENT_TYPE) THEOS_CURRENT_INSTANCE=$(THEOS_CURRENT_INSTANCE) _THEOS_CURRENT_OPERATION=compile \
		THEOS_BUILD_DIR="$(THEOS_BUILD_DIR)" _THEOS_MAKE_PARALLEL=yes$(ECHO_END)

internal-framework-compile: $(THEOS_OBJ_DIR)/$(_LOCAL_INSTANCE_TARGET)
endif

$(eval $(call _THEOS_TEMPLATE_DEFAULT_LINKING_RULE,$(_LOCAL_INSTANCE_TARGET)))

internal-framework-stage_:: shared-instance-bundle-stage

$(eval $(call __mod,instance/framework.mk))
