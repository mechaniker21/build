# No Optimizations Modules
BLUETOOTH := libbluetooth_jni bluetooth.default bluetooth.mapsapi libbt-brcm_stack audio.a2dp.default libbt-brcm_gki libbt-utils libbt-qcom_sbc_decoder libbt-brcm_bta libbt-vendor libbtprofile libbtdevice libbtcore bdt bdtest libbt-hci libosi ositests net_test_osi net_test_device net_test_btcore net_bdtool net_hci bdAddrLoader android.bluetooth.client.map android.bluetooth.client.pbap

# Disable Force ARM Instruction Set Modules
DISABLE_ARM_MODE :=

# Disable IPA Optimizations Modules
DISABLE_ANALYZER := $(BLUETOOTH)

# Disable OpenMP Modules
DISABLE_OPENMP := $(BLUETOOTH)

# Disable Memory Leak Sanitizer Modules
DISABLE_SANITIZE_LEAK := $(BLUETOOTH)

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
      my_conlyflags += -fsanitize=leak
    endif
  endif
 endif
endif
