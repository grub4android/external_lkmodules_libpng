LOCAL_DIR := $(GET_LOCAL_DIR)
MODULE := $(LOCAL_DIR)

GLOBAL_INCLUDES += $(LOCAL_DIR)

common_SRC_FILES := \
	png.c \
	pngerror.c \
	pngget.c \
	pngmem.c \
	pngpread.c \
	pngread.c \
	pngrio.c \
	pngrtran.c \
	pngrutil.c \
	pngset.c \
	pngtrans.c \
	pngwio.c \
	pngwrite.c \
	pngwtran.c \
	pngwutil.c \

ifneq ($(ARM_WITHOUT_VFP_NEON),true)
my_cflags_arm := -DPNG_ARM_NEON_OPT=2
endif

my_cflags_arm64 := -DPNG_ARM_NEON_OPT=2

# BUG: http://llvm.org/PR19472 - SLP vectorization (on ARM at least) crashes
# when we can't lower a vectorized bswap.
#my_cflags_arm += -fno-slp-vectorize

my_src_files_arm := \
			arm/arm_init.c \
			arm/filter_neon.S \
			arm/filter_neon_intrinsics.c


common_CFLAGS := -std=gnu89 #-fvisibility=hidden ## -fomit-frame-pointer
common_CFLAGS += -Wno-error -Wno-error=implicit-function-declaration

common_C_INCLUDES +=

common_COPY_HEADERS_TO := libpng
common_COPY_HEADERS := png.h pngconf.h pngusr.h

# For the device (static)
# =====================================================

MODULE_SRCS := $(addprefix $(LOCAL_DIR)/, $(common_SRC_FILES))
MODULE_CFLAGS += $(common_CFLAGS) -ftrapv

ifeq ($(ARCH),arm)
MODULE_CFLAGS += $(my_cflags_arm)
MODULE_SRCS += $(addprefix $(LOCAL_DIR)/, $(my_src_files_arm))
endif

ifeq ($(ARCH),arm64)
MODULE_CFLAGS += $(my_cflags_arm64)
MODULE_SRCS += $(addprefix $(LOCAL_DIR)/, $(my_src_files_arm))
endif

MODULE_DEPS := \
	lib/ffs \
	$(EXTERNAL_MODULES_DIR)/zlib

include make/module.mk
