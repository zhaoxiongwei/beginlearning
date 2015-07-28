LOCAL_PATH:= $(call my-dir)
MY_LOCAL_PATH = $(LOCAL_PATH)

###########################################################
# building application library 
#
include $(CLEAR_VARS)
LOCAL_MODULE := libbeginvision
LOCAL_CPP_EXTENSION := .cc .cpp
LOCAL_CPPFLAGS := -O3 -Werror -Wall -mfpu=neon -mfloat-abi=softfp 
LOCAL_CPPFLAGS += -DPOSIX -DLINUX -DANDROID
LOCAL_C_INCLUDES :=  $(MY_LOCAL_PATH)
include $(MY_LOCAL_PATH)/buildme.mk


LOCAL_SHARED_LIBRARIES := libcutils\
                          libgnustl\
                          libdl

LOCAL_LDLIBS := -llog -ljnigraphics -lm

include $(BUILD_SHARED_LIBRARY)

