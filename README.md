# Home Assistant Operating System for Rock5b

This is an unofficial fork of the awesome [Home Assistant Operating System](https://github.com/home-assistant/operating-system) which adds support for the Rock5b board.

[![Home Assistant - A project from the Open Home Foundation](https://www.openhomefoundation.org/badges/home-assistant.png)](https://www.openhomefoundation.org/)

## Getting Started

Download the latest version from the [Releases](https://github.com/nyok92/rock5b/releases) page & flash it (with Balena, armbian imager or others) to your SD card, eMMc or NVMe SSD.

## Boot from NMVe SSD

Booting HAOS from an NVMe SSD has not yet been tested.
Please see the [official Radxa site](https://wiki.radxa.com/Rock5/install/nvme) for which types of SSDs are supported.
Since the Rock5b cannot boot natively from an SSD, you need a small bootloader either in eMMC or on an SD card or in SPI flash.
It performs the initialization and then loads the boot configuration, boot script and kernel files from the boot partition of the SSD.

u-boot-rockchip-spi.bin is provided for that purpose on the Release page.
It only contains the U-Boot bootloader (TPL, SPL and main).

You will have to write it into the on board SPI flash of the Rock5b.
You can find more details about this procedure in [Radxa online docs about the Rock5b](https://wiki.radxa.com/Rock5/install/spi)
Tested with RKDevTool 2.96 & rk3588_spl_loader_v1.19.113.bin procedure on Windows

## Development

If you don't have experience with embedded systems, Buildroot or the build process for Linux distributions it is recommended to read up on these topics first (e.g. [Bootlin](https://bootlin.com/docs/) has excellent resources).

The Home Assistant Operating System documentation can be found on the [Home Assistant Developer Docs website](https://developers.home-assistant.io/docs/operating-system).
