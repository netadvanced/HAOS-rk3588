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

## Upgrading

Since this is an unofficial fork of Homeassistant OS, the OS image cannot be updated from the UI (supervisor, core and all other components can be updated just fine). Instead, the update process is triggered via SSH from the command line.

**Always create a full backup before upgrading to avoid data loss.**

Use the [hass os enable ssh app fork](https://github.com/nyok92/hassio-addons) to enable ssh root access on port 22222 (the "Terminal & SSH" Add-on will not work as it only exposes a limited shell in a container).

Connect to the device and run the following command. Replace the URL with the appropriate link from the Releases page for your device. Make sure to copy the `.raucb` URL, not the `.img.xz`.

```
rauc install https://github.com/nyok92/rock5b/releases/download/<release>/haos_<device>-<release>.raucb
```

The file will be downloaded to a temporary location in `/mnt/data/tmp/` so make sure that there is enough space on the data partition left.

```
# rauc install https://github.com/nyok92/rock5b/releases/download/ota-test/haos_rock5b-18.4.dev20240502.raucb
installing
  0% Installing
  0% Determining slot states
 10% Determining slot states done.
 10% Checking bundle
 10% Verifying signature
 20% Verifying signature done.
 20% Checking bundle done.
 20% Checking manifest contents
 30% Checking manifest contents done.
 30% Determining target install group
 40% Determining target install group done.
 40% Updating slots
 40% Checking slot boot.0
 41% Checking slot boot.0 done.
 41% Copying image to boot.0
 ...
 99% Copying image to spl.0 done.
 99% Updating slots done.
100% Installing done.
Installing `https://github.com/nyok92/rock5b/releases/download/ota-test/haos_rock5b-18.4.dev20240502.raucb` succeeded
```

Now reboot the device to switch to the new OS version.

This process won't update the SPI bootloader.
You will need to fulfill the previous SPI install procedure with the new updated SPI file available in github releases.

If there is an error during installation, run `journalctl -u rauc.service` to get an extended output log.

## Development

If you don't have experience with embedded systems, Buildroot or the build process for Linux distributions it is recommended to read up on these topics first (e.g. [Bootlin](https://bootlin.com/docs/) has excellent resources).

The Home Assistant Operating System documentation can be found on the [Home Assistant Developer Docs website](https://developers.home-assistant.io/docs/operating-system).
