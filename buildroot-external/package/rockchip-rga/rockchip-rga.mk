################################################################################
#
# ROCKCHIP_RGA
#
################################################################################

#ROCKCHIP_RGA_VERSION = 1.1.0
#ROCKCHIP_RGA_SITE = $(call github,rockchip-linux,rga,$(ROCKCHIP_RGA_VERSION))
ROCKCHIP_RGA_VERSION = develop
ROCKCHIP_RGA_SITE = $(call github,tsukumijima,RGA-rockchip,$(ROCKCHIP_RGA_VERSION))
ROCKCHIP_RGA_LICENSE = Apache-2.0, MIT
ROCKCHIP_RGA_LICENSE_FILES = SECURITY.md
ROCKCHIP_RGA_INSTALL_STAGING = YES

ROCKCHIP_RGA_CONF_OPTS = \
	-DBUILD_TEST=ON \
	-DCMAKE_STRIP=$(TARGET_STRIP)
    -DCMAKE_BUILD_TYPE=Release

$(eval $(cmake-package))
