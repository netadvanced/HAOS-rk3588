# Orange Pi 5 Plus (RK3588)

Unofficial Home Assistant OS port, maintained on the `orangepi5plus` branch of
[netadvanced/HAOS-rk3588](https://github.com/netadvanced/HAOS-rk3588), on top of
[nyok92/HAOS-rock5b](https://github.com/nyok92/HAOS-rock5b) (`rock5b-dev`).

| | |
|---|---|
| Board id / defconfig | `orangepi5plus` / `orangepi5plus_defconfig` |
| Board files | `buildroot-external/board/xunlong/orangepi5plus` |
| SoC | Rockchip RK3588 (4x A76 + 4x A55, Mali G610) |
| U-Boot | mainline v2026.10, `orangepi-5-plus-rk3588_defconfig` + `uboot.config` fragment |
| TF-A / OP-TEE | TF-A v2.15.0 BL31, OP-TEE 4.10.0, Rockchip DDR TPL blob (rkbin) |
| Linux | 7.3.3 (pinned), DTS `rockchip/rk3588-orangepi-5-plus` |
| Kernel config | `armbian-kernel.config` (7.3) + HAOS fragments + board `kernel.config` |
| Kernel patches | `patches/linux` (121 patches, the rock5b set that last built on 7.3.y) |
| U-Boot patches | `patches/uboot` (10 patches, pinned copy of the rock5b set as of Nov 2026) |

## Hardware status

| Feature | Status | Notes |
|---|---|---|
| SD card boot | works | |
| eMMC boot | expected to work | sdhci is enabled in U-Boot; flash the `.img.xz` to the eMMC |
| NVMe boot | works with SPI U-Boot | needs `u-boot-rockchip-spi-orangepi5plus.bin` in SPI NOR (see below); `PHY_ROCKCHIP_SNPS_PCIE3` is built in so the root fs on NVMe is found |
| 2x 2.5 GbE (RTL8125B) | works | r8169, port LEDs driven by `lan-leds.service` (left link, right activity) |
| Mali G610 GPU | enabled | Panthor + Mali CSF firmware, Mesa panfrost (Gallium, Vulkan, EGL, GLES, GBM) |
| Video decode/encode | enabled | rkvdec/hantro multicore patches, RKVENC + multi-RGA out of tree, Rockchip MPP/RGA, `ffmpeg-custom2` |
| WiFi / Bluetooth | M.2 E-key card dependent | firmware for common Intel/Realtek/MediaTek/Broadcom cards is included |
| OTA from the Home Assistant UI | no | unofficial build, update with RAUC (see below) |

## Install

1. Flash `haos_orangepi5plus-<version>.img.xz` to an SD card, eMMC or NVMe
   (balenaEtcher, Raspberry Pi Imager or `xzcat ... | dd`).
2. For NVMe boot only: write `u-boot-rockchip-spi-orangepi5plus.bin` to the
   16 MB SPI NOR once, e.g. from a Linux system booted on the board:
   `dd if=u-boot-rockchip-spi-orangepi5plus.bin of=/dev/mtdblock0 conv=fsync`.
   RAUC updates do not touch the SPI NOR; rewrite it when U-Boot changes.
3. Serial console: UART2 on the debug header, 1500000 8N1.

## Update

Copy `haos_orangepi5plus-<version>.raucb` to a USB stick labelled `CONFIG` and
plug it in, or from the host shell (port 22222):
`rauc install <url-or-path>/haos_orangepi5plus-<version>.raucb`, then reboot.

## Build

```sh
scripts/update-board.sh -b orangepi5plus [--from-nyok92]
```

Builds in Docker (`hassos:local`), source volume `haos-opi5plus-src`, download
and ccache volume `haos-opi5plus-cache`; artifacts go to `~/Projects/HAOS-images`.

## Differences from the Rock 5B port

- Own kernel and U-Boot patch sets and Armbian config so the board stays on the 7.3 stable
  series while `rock5b-dev` tracks 7.4-rc. When syncing from nyok92, changes to
  `rock5b_defconfig`, `radxa/rock5b/kernel.config` and the rock5b overlay must be
  ported by hand (`update-board.sh --from-nyok92` stops and lists them).
- Two RTL8125B NICs instead of one; `lan-leds` finds them from
  `/sys/class/leds/*::lan` instead of a fixed interface name.
- `PHY_ROCKCHIP_SNPS_PCIE3=y` for NVMe root (HAOS has no initramfs).
