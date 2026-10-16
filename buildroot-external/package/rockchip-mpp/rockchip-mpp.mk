################################################################################
#
# mpp
#
################################################################################

MPP_VERSION = 1.1.0
MPP_SITE = $(call github,rockchip-linux,mpp,$(MPP_VERSION))
MPP_LICENSE = Apache-2.0, MIT
MPP_LICENSE_FILES = Apache-2.0 MIT
MPP_INSTALL_STAGING = YES

MPP_CONF_OPTS = \
	-DBUILD_TEST=OFF \
	-DCMAKE_STRIP=$(TARGET_STRIP)

$(eval $(cmake-package))
