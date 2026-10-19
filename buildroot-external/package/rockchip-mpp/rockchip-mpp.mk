################################################################################
#
# ROCKCHIP_MPP
#
################################################################################

#ROCKCHIP_MPP_VERSION = 1.1.0
#ROCKCHIP_MPP_SITE = $(call github,rockchip-linux,mpp,$(ROCKCHIP_MPP_VERSION))
ROCKCHIP_MPP_VERSION = 750e76ec2d9287babfaf08c8bf395ebc5e8778ea
ROCKCHIP_MPP_SITE = $(call github,tsukumijima,mpp-rockchip,$(ROCKCHIP_MPP_VERSION))
ROCKCHIP_MPP_LICENSE = Apache-2.0, MIT
ROCKCHIP_MPP_LICENSE_FILES = SECURITY.md
ROCKCHIP_MPP_INSTALL_STAGING = YES

ROCKCHIP_MPP_CONF_OPTS = \
	-DBUILD_TEST=ON \
	-DCMAKE_STRIP=$(TARGET_STRIP) \
    -DCMAKE_BUILD_TYPE=Release

$(eval $(cmake-package))
