BLUETOOTH += camera.msm8084 gps.msm8084 gralloc.msm8084
DISABLE_ARM_MODE := libfs_mgr liblog libunwind libnetutils libziparchive libsync libusbhost libjnigraphics libstagefright_avc_common libmmcamera_interface pppd clatd libsoftkeymasterdevice sdcard logd mm-qcamera-app racoon libdiskconfig libmm-qcamera librmnetctl libjavacore camera.% libandroid_servers libmedia_jni librs_jni libhwui libandroidfw linker $(BLUETOOTH)
DISABLE_ANALYZER := libbluetooth_jni bluetooth.mapsapi bluetooth.default bluetooth.mapsapi libbt-brcm_stack audio.a2dp.default libbt-brcm_gki libbt-utils libbt-qcom_sbc_decoder libbt-brcm_bta libbt-brcm_stack libbt-vendor libbtprofile libbtdevice libbtcore bdt bdtest libbt-hci libosi ositests libbluetooth_jni net_test_osi net_test_device net_test_btcore net_bdtool net_hci bdAddrLoader camera.msm8084 gps.msm8084 gralloc.msm8084 keystore.msm8084 memtrack.msm8084 hwcomposer.msm8084 audio.primary.msm8084 $(BLUETOOTH)
DISABLE_OPENMP := libc_tzcode libbluetooth_jni_32 *libblas libF77blas libdl libjni_latinime $(BLUETOOTH)
DISABLE_SANITIZE_LEAK := libc_dns libc_tzcode $(BLUETOOTH)
DISABLE_O3 := libaudioflinger $(BLUETOOTH)
DISABLE_ARCHI := libaudioflinger $(BLUETOOTH)
DISABLE_CORTEX_STRINGS := $(BLUETOOTH)
CMREMIX_IGNORE_RECOVERY_SIZE := true

# Clean local module flags
my_cflags :=  $(filter-out -Wall -Werror -Werror=% -g,$(my_cflags))
my_cppflags :=  $(filter-out -Wall -Werror -Werror=% -g,$(my_cppflags))

# Force ARM Instruction Set
ifeq ($(strip $(USE_ARM_MODE)),true)
 ifndef LOCAL_IS_HOST_MODULE
  ifneq (1,$(words $(filter $(DISABLE_ARM_MODE),$(LOCAL_MODULE))))
    ifeq ($(LOCAL_ARM_MODE),)
      LOCAL_ARM_MODE := arm
      my_cflags += -marm
      my_cflags :=  $(filter-out -mthumb,$(my_cflags))
    endif
  else
    LOCAL_ARM_MODE := thumb
    my_cflags += -mthumb
    my_cflags :=  $(filter-out -marm,$(my_cflags))
  endif
 endif
endif

# IPA Optimizations
ifeq ($(strip $(IPA_OPTIMIZATIONS)),true)
 ifndef LOCAL_IS_HOST_MODULE
  ifeq (,$(filter true,$(my_clang)))
    ifneq (1,$(words $(filter $(DISABLE_ANALYZER),$(LOCAL_MODULE))))
      my_cflags += -fipa-sra -fipa-pta -fipa-cp -fipa-cp-clone
    endif
  else
    ifneq (1,$(words $(filter $(DISABLE_ANALYZER),$(LOCAL_MODULE))))
      my_cflags += -analyze -analyzer-purge
    endif
  endif
 endif
endif

# OpenMP
ifeq ($(strip $(OPENMP_OPTIMIZATIONS)),true)
 ifndef LOCAL_IS_HOST_MODULE
  ifneq (1,$(words $(filter $(DISABLE_OPENMP),$(LOCAL_MODULE))))
    my_cflags += -lgomp -lgcc -fopenmp
    my_ldflags += -fopenmp
  endif
 endif
endif

# Memory Leak Sanitizer
ifeq ($(strip $(MEMORY_LEAK_OPTIMIZATIONS)),true)
 ifndef LOCAL_IS_HOST_MODULE
  ifeq (,$(filter true,$(my_clang)))
    ifeq ($(filter $(DISABLE_SANITIZE_LEAK), $(LOCAL_MODULE)),)
      my_cflags += -fsanitize=leak
    endif
  endif
 endif
endif

# Optimization Level 3
ifeq ($(strip $(O3_OPTIMIZATIONS)),true)
 ifndef LOCAL_IS_HOST_MODULE
  ifeq (,$(filter true,$(my_clang)))
    ifeq ($(filter $(DISABLE_O3), $(LOCAL_MODULE)),)
      my_cflags += -O3
    endif
  endif
 endif
endif

# ArchiDroid flags
ifeq ($(strip $(ARCHIDROID_OPTIMIZATIONS)),true)
 ifndef LOCAL_IS_HOST_MODULE
  ifeq (,$(filter true,$(my_clang)))
    ifeq ($(filter $(DISABLE_ARCHI), $(LOCAL_MODULE)),)
      my_cflags += -pipe -fgcse-las -fgcse-sm -fivopts -fomit-frame-pointer -frename-registers -fsection-anchors -ftree-loop-im -ftree-loop-ivcanon -fweb -fira-hoist-pressure -fira-loop-pressure -Wno-error=array-bounds -Wno-error=clobbered -Wno-error=maybe-uninitialized -Wno-error=parentheses -Wno-error=strict-overflow -Wno-error=unused-variable
      my_ldflags += -Wl,--as-needed -Wl,--gc-sections -Wl,--relax -Wl,--sort-common
    endif
  endif
 endif
endif

# Link binaries with Cortex string routines
ifndef LOCAL_IS_HOST_MODULE
  ifeq ($(filter $(DISABLE_CORTEX_STRINGS), $(LOCAL_MODULE)),)
    my_ldflags += -L$(BUILD_SYSTEM)/../libs/$(TARGET_ARCH) -lcortex-strings
    ifneq ($(filter krait a9 a15, $(LOCAL_MODULE)),)
      my_ldflags += -lbionic-$(TARGET_CPU_VARIANT)
    endif
    ifeq ($(TARGET_2ND_CPU_VARIANT), cortex-a53.a57)
      my_ldflags += -lbionic-a15
    endif
  endif
endif
