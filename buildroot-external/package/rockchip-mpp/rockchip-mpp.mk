ROCKCHIP_MPP_VERSION = 14729dd578e570e5f00fd1dd2113f5429012d64b       # tag or full commit hash
ROCKCHIP_MPP_SITE = https://github.com/rockchip-linux/mpp.git
ROCKCHIP_MPP_SITE_METHOD = git
ROCKCHIP_MPP_INSTALL_STAGING = YES
ROCKCHIP_MPP_LICENSE = LGPL-2.1+
ROCKCHIP_MPP_LICENSE_FILES = COPYING.LGPLv2.1


ROCKCHIP_MPP_CPE_ID_VENDOR = ffmpeg

ROCKCHIP_MPP_CONF_OPTS = \
	--prefix=/usr \
	--enable-avfilter

ROCKCHIP_MPP_DEPENDENCIES += host-pkgconf
ROCKCHIP_MPP_CFLAGS = $(TARGET_CFLAGS)

ifeq ($(BR2_TOOLCHAIN_HAS_GCC_BUG_85180),y)
ROCKCHIP_MPP_CONF_OPTS += --disable-optimizations
ROCKCHIP_MPP_CFLAGS += -O0
endif

ifeq ($(BR2_TOOLCHAIN_HAS_GCC_BUG_68485),y)
ROCKCHIP_MPP_CONF_OPTS += --disable-optimizations
ROCKCHIP_MPP_CFLAGS += -O0
endif

ifeq ($(BR2_ARM_INSTRUCTIONS_THUMB),y)
ROCKCHIP_MPP_CFLAGS += -marm
endif

ROCKCHIP_MPP_CONF_ENV += CFLAGS="$(ROCKCHIP_MPP_CFLAGS)"
ROCKCHIP_MPP_CONF_OPTS += $(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_EXTRACONF))

# Override ROCKCHIP_MPP_CONFIGURE_CMDS: FFmpeg does not support --target and others
define ROCKCHIP_MPP_CONFIGURE_CMDS
	(cd $(ROCKCHIP_MPP_SRCDIR) && rm -rf config.cache && \
	$(TARGET_CONFIGURE_OPTS) \
	$(TARGET_CONFIGURE_ARGS) \
	$(ROCKCHIP_MPP_CONF_ENV) \
	./configure \
		--enable-cross-compile \
		--cross-prefix=$(TARGET_CROSS) \
		--sysroot=$(STAGING_DIR) \
		--host-cc="$(HOSTCC)" \
		--arch=$(BR2_ARCH) \
		--target-os="linux" \
		--disable-stripping \
		--pkg-config="$(PKG_CONFIG_HOST_BINARY)" \
		$(SHARED_STATIC_LIBS_OPTS) \
		$(ROCKCHIP_MPP_CONF_OPTS) \
	)
endef

define ROCKCHIP_MPP_REMOVE_EXAMPLE_SRC_FILES
	rm -rf $(TARGET_DIR)/usr/share/ffmpeg/examples
endef
ROCKCHIP_MPP_POST_INSTALL_TARGET_HOOKS += ROCKCHIP_MPP_REMOVE_EXAMPLE_SRC_FILES

$(eval $(autotools-package))
