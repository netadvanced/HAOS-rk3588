ROCKCHIP_MPP_VERSION = 14729dd578e570e5f00fd1dd2113f5429012d64b       # tag or full commit hash
ROCKCHIP_MPP_SITE = https://github.com/rockchip-linux/mpp.git
ROCKCHIP_MPP_SITE_METHOD = git
ROCKCHIP_MPP_INSTALL_STAGING = YES
ROCKCHIP_MPP_LICENSE = LGPL-2.1+
ROCKCHIP_MPP_LICENSE_FILES = COPYING.LGPLv2.1


ROCKCHIP_MPP_CPE_ID_VENDOR = ffmpeg

ROCKCHIP_MPP_CONF_OPTS = \
	--prefix=/usr \
	--enable-avfilter \
	--disable-version3 \
	--enable-logging \
	--enable-optimizations \
	--disable-extra-warnings \
	--enable-avdevice \
	--enable-avcodec \
	--enable-avformat \
	--enable-network \
	--disable-gray \
	--enable-swscale-alpha \
	--disable-small \
	--disable-dxva2 \
	--enable-runtime-cpudetect \
	--disable-hardcoded-tables \
	--disable-mipsdsp \
	--disable-mipsdspr2 \
	--disable-msa \
	--enable-hwaccels \
	--disable-cuda \
	--disable-cuvid \
	--disable-nvenc \
	--disable-avisynth \
	--disable-frei0r \
	--disable-libopencore-amrnb \
	--disable-libopencore-amrwb \
	--disable-libdc1394 \
	--disable-libgsm \
	--disable-libilbc \
	--disable-libvo-amrwbenc \
	--disable-symver \
	--disable-doc

ROCKCHIP_MPP_DEPENDENCIES += host-pkgconf

ifeq ($(BR2_PACKAGE_HAS_UDEV),y)
ROCKCHIP_MPP_DEPENDENCIES += udev
ROCKCHIP_MPP_CONF_OPTS += --enable-libudev --enable-v4l2-request
endif

ifeq ($(BR2_PACKAGE_ROCKCHIP_MPP_GPL),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-gpl
else
ROCKCHIP_MPP_CONF_OPTS += --disable-gpl
endif

ifeq ($(BR2_PACKAGE_ROCKCHIP_MPP_NONFREE),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-nonfree
else
ROCKCHIP_MPP_CONF_OPTS += --disable-nonfree
endif

ifeq ($(BR2_PACKAGE_ROCKCHIP_MPP_FFMPEG),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-ffmpeg
else
ROCKCHIP_MPP_CONF_OPTS += --disable-ffmpeg
endif

ifeq ($(BR2_PACKAGE_ROCKCHIP_MPP_FFPLAY),y)
ROCKCHIP_MPP_DEPENDENCIES += sdl2
ROCKCHIP_MPP_CONF_OPTS += --enable-ffplay
ROCKCHIP_MPP_CONF_ENV += SDL_CONFIG=$(STAGING_DIR)/usr/bin/sdl2-config
else
ROCKCHIP_MPP_CONF_OPTS += --disable-ffplay
endif

ifeq ($(BR2_PACKAGE_JACK1),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libjack
ROCKCHIP_MPP_DEPENDENCIES += jack1
else ifeq ($(BR2_PACKAGE_JACK2),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libjack
ROCKCHIP_MPP_DEPENDENCIES += jack2
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libjack
endif

ifeq ($(BR2_PACKAGE_PULSEAUDIO),y)
ROCKCHIP_MPP_DEPENDENCIES += pulseaudio
ROCKCHIP_MPP_CONF_OPTS += --enable-libpulse
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libpulse
endif

ifeq ($(BR2_PACKAGE_LIBV4L),y)
ROCKCHIP_MPP_DEPENDENCIES += libv4l
ROCKCHIP_MPP_CONF_OPTS += --enable-libv4l2
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libv4l2
endif

ifeq ($(BR2_PACKAGE_ROCKCHIP_MPP_FFPROBE),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-ffprobe
else
ROCKCHIP_MPP_CONF_OPTS += --disable-ffprobe
endif

ifeq ($(BR2_PACKAGE_ROCKCHIP_MPP_XCBGRAB),y)
ROCKCHIP_MPP_CONF_OPTS += \
	--enable-libxcb \
	--enable-libxcb-shape \
	--enable-libxcb-shm \
	--enable-libxcb-xfixes
ROCKCHIP_MPP_DEPENDENCIES += libxcb
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libxcb
endif

ifeq ($(BR2_PACKAGE_ROCKCHIP_MPP_SWSCALE),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-swscale
else
ROCKCHIP_MPP_CONF_OPTS += --disable-swscale
endif

ifneq ($(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_ENCODERS)),all)
ROCKCHIP_MPP_CONF_OPTS += --disable-encoders \
	$(foreach x,$(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_ENCODERS)),--enable-encoder=$(x))
endif

ifneq ($(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_DECODERS)),all)
ROCKCHIP_MPP_CONF_OPTS += --disable-decoders \
	$(foreach x,$(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_DECODERS)),--enable-decoder=$(x))
endif

ifneq ($(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_MUXERS)),all)
ROCKCHIP_MPP_CONF_OPTS += --disable-muxers \
	$(foreach x,$(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_MUXERS)),--enable-muxer=$(x))
endif

ifneq ($(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_DEMUXERS)),all)
ROCKCHIP_MPP_CONF_OPTS += --disable-demuxers \
	$(foreach x,$(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_DEMUXERS)),--enable-demuxer=$(x))
endif

ifneq ($(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_PARSERS)),all)
ROCKCHIP_MPP_CONF_OPTS += --disable-parsers \
	$(foreach x,$(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_PARSERS)),--enable-parser=$(x))
endif

ifneq ($(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_BSFS)),all)
ROCKCHIP_MPP_CONF_OPTS += --disable-bsfs \
	$(foreach x,$(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_BSFS)),--enable-bsf=$(x))
endif

ifneq ($(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_PROTOCOLS)),all)
ROCKCHIP_MPP_CONF_OPTS += --disable-protocols \
	$(foreach x,$(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_PROTOCOLS)),--enable-protocol=$(x))
endif

ifneq ($(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_FILTERS)),all)
ROCKCHIP_MPP_CONF_OPTS += --disable-filters \
	$(foreach x,$(call qstrip,$(BR2_PACKAGE_ROCKCHIP_MPP_FILTERS)),--enable-filter=$(x))
endif

ifeq ($(BR2_PACKAGE_ROCKCHIP_MPP_INDEVS),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-indevs
ifeq ($(BR2_PACKAGE_ALSA_LIB),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-alsa
ROCKCHIP_MPP_DEPENDENCIES += alsa-lib
else
ROCKCHIP_MPP_CONF_OPTS += --disable-alsa
endif
else
ROCKCHIP_MPP_CONF_OPTS += --disable-indevs
endif

ifeq ($(BR2_PACKAGE_ROCKCHIP_MPP_OUTDEVS),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-outdevs
ifeq ($(BR2_PACKAGE_ALSA_LIB),y)
ROCKCHIP_MPP_DEPENDENCIES += alsa-lib
endif
else
ROCKCHIP_MPP_CONF_OPTS += --disable-outdevs
endif

ifeq ($(BR2_TOOLCHAIN_HAS_THREADS),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-pthreads
else
ROCKCHIP_MPP_CONF_OPTS += --disable-pthreads
endif

ifeq ($(BR2_PACKAGE_ZLIB),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-zlib
ROCKCHIP_MPP_DEPENDENCIES += zlib
else
ROCKCHIP_MPP_CONF_OPTS += --disable-zlib
endif

ifeq ($(BR2_PACKAGE_BZIP2),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-bzlib
ROCKCHIP_MPP_DEPENDENCIES += bzip2
else
ROCKCHIP_MPP_CONF_OPTS += --disable-bzlib
endif

ifeq ($(BR2_PACKAGE_FDK_AAC)$(BR2_PACKAGE_ROCKCHIP_MPP_NONFREE),yy)
ROCKCHIP_MPP_CONF_OPTS += --enable-libfdk-aac
ROCKCHIP_MPP_DEPENDENCIES += fdk-aac
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libfdk-aac
endif

ifeq ($(BR2_PACKAGE_ROCKCHIP_MPP_GPL)$(BR2_PACKAGE_LIBCDIO_PARANOIA),yy)
ROCKCHIP_MPP_CONF_OPTS += --enable-libcdio
ROCKCHIP_MPP_DEPENDENCIES += libcdio-paranoia
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libcdio
endif

ifeq ($(BR2_PACKAGE_GNUTLS),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-gnutls --disable-openssl
ROCKCHIP_MPP_DEPENDENCIES += gnutls
else
ROCKCHIP_MPP_CONF_OPTS += --disable-gnutls
ifeq ($(BR2_PACKAGE_OPENSSL),y)
# openssl isn't license compatible with GPL
ifeq ($(BR2_PACKAGE_ROCKCHIP_MPP_GPL)x$(BR2_PACKAGE_ROCKCHIP_MPP_NONFREE),yx)
ROCKCHIP_MPP_CONF_OPTS += --disable-openssl
else
ROCKCHIP_MPP_CONF_OPTS += --enable-openssl
ROCKCHIP_MPP_DEPENDENCIES += openssl
endif
else
ROCKCHIP_MPP_CONF_OPTS += --disable-openssl
endif
endif

ifeq ($(BR2_PACKAGE_LIBDRM),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libdrm
ROCKCHIP_MPP_DEPENDENCIES += libdrm
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libdrm
endif

ifeq ($(BR2_PACKAGE_LIBOPENH264),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libopenh264
ROCKCHIP_MPP_DEPENDENCIES += libopenh264
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libopenh264
endif

ifeq ($(BR2_PACKAGE_LIBVORBIS),y)
ROCKCHIP_MPP_DEPENDENCIES += libvorbis
ROCKCHIP_MPP_CONF_OPTS += \
	--enable-libvorbis \
	--enable-muxer=ogg \
	--enable-encoder=libvorbis
endif

ifeq ($(BR2_PACKAGE_LIBVA),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-vaapi
ROCKCHIP_MPP_DEPENDENCIES += libva
else
ROCKCHIP_MPP_CONF_OPTS += --disable-vaapi
endif

ifeq ($(BR2_PACKAGE_LIBVDPAU),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-vdpau
ROCKCHIP_MPP_DEPENDENCIES += libvdpau
else
ROCKCHIP_MPP_CONF_OPTS += --disable-vdpau
endif

ifeq ($(BR2_PACKAGE_OPENCV3_LIB_IMGPROC),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libopencv
ROCKCHIP_MPP_DEPENDENCIES += opencv3
# To avoid a circular dependency only use opencv if opencv itself does
# not depend on ffmpeg.
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libopencv
endif

ifeq ($(BR2_PACKAGE_OPUS),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libopus
ROCKCHIP_MPP_DEPENDENCIES += opus
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libopus
endif

ifeq ($(BR2_PACKAGE_LIBVPX),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libvpx
ROCKCHIP_MPP_DEPENDENCIES += libvpx
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libvpx
endif

ifeq ($(BR2_PACKAGE_LIBASS),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libass
ROCKCHIP_MPP_DEPENDENCIES += libass
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libass
endif

ifeq ($(BR2_PACKAGE_LIBBLURAY),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libbluray
ROCKCHIP_MPP_DEPENDENCIES += libbluray
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libbluray
endif

ifeq ($(BR2_PACKAGE_RTMPDUMP),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-librtmp
ROCKCHIP_MPP_DEPENDENCIES += rtmpdump
else
ROCKCHIP_MPP_CONF_OPTS += --disable-librtmp
endif

ifeq ($(BR2_PACKAGE_LAME),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libmp3lame
ROCKCHIP_MPP_DEPENDENCIES += lame
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libmp3lame
endif

ifeq ($(BR2_PACKAGE_LIBMODPLUG),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libmodplug
ROCKCHIP_MPP_DEPENDENCIES += libmodplug
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libmodplug
endif

ifeq ($(BR2_PACKAGE_LIBOPENMPT),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libopenmpt
ROCKCHIP_MPP_DEPENDENCIES += libopenmpt
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libopenmpt
endif

ifeq ($(BR2_PACKAGE_LIBSOXR),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libsoxr
ROCKCHIP_MPP_DEPENDENCIES += libsoxr
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libsoxr
endif

ifeq ($(BR2_PACKAGE_SPEEX),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libspeex
ROCKCHIP_MPP_DEPENDENCIES += speex
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libspeex
endif

ifeq ($(BR2_PACKAGE_LIBTHEORA),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libtheora
ROCKCHIP_MPP_DEPENDENCIES += libtheora
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libtheora
endif

ifeq ($(BR2_PACKAGE_LIBICONV),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-iconv
ROCKCHIP_MPP_DEPENDENCIES += libiconv
else
ROCKCHIP_MPP_CONF_OPTS += --disable-iconv
endif

ifeq ($(BR2_PACKAGE_LIBXML2),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libxml2
ROCKCHIP_MPP_DEPENDENCIES += libxml2
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libxml2
endif

# ffmpeg freetype support require fenv.h which is only
# available/working on glibc.
# The microblaze variant doesn't provide the needed exceptions
ifeq ($(BR2_PACKAGE_FREETYPE)$(BR2_TOOLCHAIN_USES_GLIBC)x$(BR2_microblaze),yyx)
ROCKCHIP_MPP_CONF_OPTS += --enable-libfreetype
ROCKCHIP_MPP_DEPENDENCIES += freetype
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libfreetype
endif

ifeq ($(BR2_PACKAGE_FONTCONFIG),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-fontconfig
ROCKCHIP_MPP_DEPENDENCIES += fontconfig
else
ROCKCHIP_MPP_CONF_OPTS += --disable-fontconfig
endif

ifeq ($(BR2_PACKAGE_LIBFRIBIDI),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libfribidi
ROCKCHIP_MPP_DEPENDENCIES += libfribidi
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libfribidi
endif

ifeq ($(BR2_PACKAGE_OPENJPEG),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libopenjpeg
ROCKCHIP_MPP_DEPENDENCIES += openjpeg
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libopenjpeg
endif

ifeq ($(BR2_PACKAGE_X264)$(BR2_PACKAGE_ROCKCHIP_MPP_GPL),yy)
ROCKCHIP_MPP_CONF_OPTS += --enable-libx264
ROCKCHIP_MPP_DEPENDENCIES += x264
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libx264
endif

ifeq ($(BR2_PACKAGE_X265)$(BR2_PACKAGE_ROCKCHIP_MPP_GPL),yy)
ROCKCHIP_MPP_CONF_OPTS += --enable-libx265
ROCKCHIP_MPP_DEPENDENCIES += x265
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libx265
endif

ifeq ($(BR2_PACKAGE_DAV1D),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-libdav1d
ROCKCHIP_MPP_DEPENDENCIES += dav1d
else
ROCKCHIP_MPP_CONF_OPTS += --disable-libdav1d
endif

ifeq ($(BR2_X86_CPU_HAS_MMX),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-x86asm
ROCKCHIP_MPP_DEPENDENCIES += host-nasm
else
ROCKCHIP_MPP_CONF_OPTS += --disable-x86asm
ROCKCHIP_MPP_CONF_OPTS += --disable-mmx
endif

ifeq ($(BR2_X86_CPU_HAS_SSE),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-sse
else
ROCKCHIP_MPP_CONF_OPTS += --disable-sse
endif

ifeq ($(BR2_X86_CPU_HAS_SSE2),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-sse2
else
ROCKCHIP_MPP_CONF_OPTS += --disable-sse2
endif

ifeq ($(BR2_X86_CPU_HAS_SSE3),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-sse3
else
ROCKCHIP_MPP_CONF_OPTS += --disable-sse3
endif

ifeq ($(BR2_X86_CPU_HAS_SSSE3),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-ssse3
else
ROCKCHIP_MPP_CONF_OPTS += --disable-ssse3
endif

ifeq ($(BR2_X86_CPU_HAS_SSE4),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-sse4
else
ROCKCHIP_MPP_CONF_OPTS += --disable-sse4
endif

ifeq ($(BR2_X86_CPU_HAS_SSE42),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-sse42
else
ROCKCHIP_MPP_CONF_OPTS += --disable-sse42
endif

ifeq ($(BR2_X86_CPU_HAS_AVX),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-avx
else
ROCKCHIP_MPP_CONF_OPTS += --disable-avx
endif

ifeq ($(BR2_X86_CPU_HAS_AVX2),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-avx2
else
ROCKCHIP_MPP_CONF_OPTS += --disable-avx2
endif

# Explicitly disable everything that doesn't match for ARM
# FFMPEG "autodetects" by compiling an extended instruction via AS
# This works on compilers that aren't built for generic by default
ifeq ($(BR2_ARM_CPU_ARMV4),y)
ROCKCHIP_MPP_CONF_OPTS += --disable-armv5te
endif
ifeq ($(BR2_ARM_CPU_ARMV6)$(BR2_ARM_CPU_ARMV7A),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-armv6
else
ROCKCHIP_MPP_CONF_OPTS += --disable-armv6 --disable-armv6t2
endif
ifeq ($(BR2_ARM_CPU_HAS_VFPV2),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-vfp
else
ROCKCHIP_MPP_CONF_OPTS += --disable-vfp
endif
ifeq ($(BR2_ARM_CPU_HAS_NEON),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-neon
else ifeq ($(BR2_aarch64),y)
ROCKCHIP_MPP_CONF_OPTS += --enable-neon
else
ROCKCHIP_MPP_CONF_OPTS += --disable-neon
endif

ifeq ($(BR2_mips)$(BR2_mipsel)$(BR2_mips64)$(BR2_mips64el),y)
ifeq ($(BR2_MIPS_SOFT_FLOAT),y)
ROCKCHIP_MPP_CONF_OPTS += --disable-mipsfpu
else
ROCKCHIP_MPP_CONF_OPTS += --enable-mipsfpu
endif

# Fix build failure on several missing assembly instructions
ROCKCHIP_MPP_CONF_OPTS += --disable-asm
endif # MIPS

ifeq ($(BR2_POWERPC_CPU_HAS_ALTIVEC):$(BR2_powerpc64le),y:)
ROCKCHIP_MPP_CONF_OPTS += --enable-altivec
else ifeq ($(BR2_POWERPC_CPU_HAS_VSX):$(BR2_powerpc64le),y:y)
# On LE, ffmpeg AltiVec support needs VSX intrinsics, and VSX
# is an extension to AltiVec.
ROCKCHIP_MPP_CONF_OPTS += --enable-altivec
else
ROCKCHIP_MPP_CONF_OPTS += --disable-altivec
endif

# Uses __atomic_fetch_add_4
ifeq ($(BR2_TOOLCHAIN_HAS_LIBATOMIC),y)
ROCKCHIP_MPP_CONF_OPTS += --extra-libs=-latomic
endif

ifeq ($(BR2_STATIC_LIBS),)
ROCKCHIP_MPP_CONF_OPTS += --enable-pic
else
ROCKCHIP_MPP_CONF_OPTS += --disable-pic
endif

# Default to --cpu=generic for MIPS architecture, in order to avoid a
# warning from ffmpeg's configure script.
ifeq ($(BR2_mips)$(BR2_mipsel)$(BR2_mips64)$(BR2_mips64el),y)
ROCKCHIP_MPP_CONF_OPTS += --cpu=generic
else ifneq ($(GCC_TARGET_CPU),)
ROCKCHIP_MPP_CONF_OPTS += --cpu="$(GCC_TARGET_CPU)"
else ifneq ($(GCC_TARGET_ARCH),)
ROCKCHIP_MPP_CONF_OPTS += --cpu="$(GCC_TARGET_ARCH)"
endif

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
