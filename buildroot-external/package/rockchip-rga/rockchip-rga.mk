################################################################################
#
# ROCKCHIP_RGA
#
################################################################################

ROCKCHIP_RGA_VERSION = master
ROCKCHIP_RGA_SITE = $(call github,tsukumijima,librga-rockchip,$(ROCKCHIP_RGA_VERSION))
ROCKCHIP_RGA_LICENSE = Apache-2.0
ROCKCHIP_RGA_LICENSE_FILES = CHANGELOG.md
ROCKCHIP_RGA_INSTALL_STAGING = YES

ROCKCHIP_RGA_CONF_OPTS = \
	-DCMAKE_STRIP=$(TARGET_STRIP) \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_BUILD_TARGET=buildroot

$(eval $(cmake-package))
