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

ROCKCHIP_RGA_DEPENDENCIES = libdrm

ROCKCHIP_RGA_CONF_OPTS = \
	-Dlibdrm=true \
	-Dlibrga_demo=false

$(eval $(meson-package))
