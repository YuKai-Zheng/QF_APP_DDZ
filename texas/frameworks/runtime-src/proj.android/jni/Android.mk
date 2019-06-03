LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE          := ferry_core_android
LOCAL_MODULE_FILENAME := ferry_core_android_static
LOCAL_SRC_FILES := libferry_core_android.a

include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := \
../../Classes/runtime/Landscape_png.cpp \
../../Classes/runtime/PlayDisable_png.cpp \
../../Classes/runtime/PlayEnable_png.cpp \
../../Classes/runtime/Portrait_png.cpp \
../../Classes/runtime/Shine_png.cpp \
../../Classes/runtime/Runtime.cpp \
../../Classes/runtime/Protos.pb.cc \
../../Classes/VisibleRect.cpp \
../../Classes/AppDelegate.cpp \
../../Classes/ConfigParser.cpp \
lua/Runtime_android.cpp \
lua/main.cpp

LOCAL_SRC_FILES += \
	../../Classes/ferry/Ferry.cpp
	
LOCAL_SRC_FILES += \
	../../Classes/script_ferry/lua_ferry_auto.cpp \
	../../Classes/script_ferry/lua_ferry_manual.cpp \
	../../Classes/script_ferry/ScriptCallbackEntry.cpp \
	../../Classes/script_ferry/ScriptFerry.cpp
LOCAL_SRC_FILES += \
	../../Classes/qf/crypto/md5/md5.cpp \
	../../Classes/qf/qf_auto_bindings.cpp \
    ../../Classes/qf/qf_manual_bindings.cpp \
	../../Classes/qf/QNative.cpp \
	../../Classes/qf/QUtil.cpp \
	../../Classes/lfs/lfs.cc

LOCAL_SRC_FILES += \
				   ../../protobuf-2.5.0/src/google/protobuf/io/coded_stream.cc                \
				   ../../protobuf-2.5.0/src/google/protobuf/extension_set_heavy.cc            \
				   ../../protobuf-2.5.0/src/google/protobuf/stubs/common.cc                   \
				   ../../protobuf-2.5.0/src/google/protobuf/descriptor.cc                     \
				   ../../protobuf-2.5.0/src/google/protobuf/descriptor.pb.cc                  \
				   ../../protobuf-2.5.0/src/google/protobuf/descriptor_database.cc            \
				   ../../protobuf-2.5.0/src/google/protobuf/dynamic_message.cc                \
				   ../../protobuf-2.5.0/src/google/protobuf/extension_set.cc                  \
				   ../../protobuf-2.5.0/src/google/protobuf/generated_message_reflection.cc   \
				   ../../protobuf-2.5.0/src/google/protobuf/generated_message_util.cc         \
				   ../../protobuf-2.5.0/src/google/protobuf/io/gzip_stream.cc                 \
				   ../../protobuf-2.5.0/src/google/protobuf/compiler/importer.cc              \
				   ../../protobuf-2.5.0/src/google/protobuf/message.cc                        \
				   ../../protobuf-2.5.0/src/google/protobuf/message_lite.cc                   \
				   ../../protobuf-2.5.0/src/google/protobuf/stubs/once.cc                     \
				   ../../protobuf-2.5.0/src/google/protobuf/compiler/parser.cc                \
				   ../../protobuf-2.5.0/src/google/protobuf/io/printer.cc                     \
				   ../../protobuf-2.5.0/src/google/protobuf/reflection_ops.cc                 \
				   ../../protobuf-2.5.0/src/google/protobuf/repeated_field.cc                 \
				   ../../protobuf-2.5.0/src/google/protobuf/service.cc                        \
				   ../../protobuf-2.5.0/src/google/protobuf/stubs/structurally_valid.cc       \
				   ../../protobuf-2.5.0/src/google/protobuf/stubs/strutil.cc                  \
				   ../../protobuf-2.5.0/src/google/protobuf/stubs/substitute.cc               \
				   ../../protobuf-2.5.0/src/google/protobuf/text_format.cc                    \
				   ../../protobuf-2.5.0/src/google/protobuf/io/tokenizer.cc                   \
				   ../../protobuf-2.5.0/src/google/protobuf/unknown_field_set.cc              \
				   ../../protobuf-2.5.0/src/google/protobuf/wire_format.cc                    \
				   ../../protobuf-2.5.0/src/google/protobuf/wire_format_lite.cc               \
				   ../../protobuf-2.5.0/src/google/protobuf/io/zero_copy_stream.cc            \
				   ../../protobuf-2.5.0/src/google/protobuf/io/zero_copy_stream_impl.cc       \
				   ../../protobuf-2.5.0/src/google/protobuf/io/zero_copy_stream_impl_lite.cc  \
				   ../../protobuf-2.5.0/src/google/protobuf/stubs/stringprintf.cc


LOCAL_SRC_FILES += \
	../../Classes/luapb/LuaPB.cc \
	../../Classes/luapb/ProtoImporter.cc

LOCAL_SRC_FILES += \
	../../Classes/qf/shaders/ScreenCaptureUtil.cpp \
	../../Classes/qf/shaders/ShaderBox.cpp \
	../../Classes/qf/shaders/SpriteBlur.cpp \
	../../Classes/qf/shaders/StackBlur.cpp \
	../../Classes/qf/shaders/StackGrey.cpp \
    ../../Classes/qf/shaders/StackHighlight.cpp \
	../../Classes/qf/actions/MoveCircle.cpp

LOCAL_C_INCLUDES := \
$(LOCAL_PATH)/../../Classes/runtime \
$(LOCAL_PATH)/../../../cocos2d-x/cocos/base \
$(LOCAL_PATH)/../../Classes \
$(LOCAL_PATH)/../../protobuf-2.5.0/src/

LOCAL_STATIC_LIBRARIES := curl_static_prebuilt
LOCAL_STATIC_LIBRARIES += ferry_core_android

LOCAL_WHOLE_STATIC_LIBRARIES := cocos_lua_static

include $(BUILD_SHARED_LIBRARY)

$(call import-module,scripting/lua-bindings)

