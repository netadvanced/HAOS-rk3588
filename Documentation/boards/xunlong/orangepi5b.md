# Orange Pi 5B (RK3588S)

Unofficial Home Assistant OS port, maintained on the `orangepi5b` branch of
[netadvanced/HAOS-rk3588](https://github.com/netadvanced/HAOS-rk3588). It is
derived from the [Orange Pi 5 Plus port](orangepi5plus.md) and shares its
kernel, kernel patch set and U-Boot patches.

| | |
|---|---|
| Board id / defconfig | `orangepi5b` / `orangepi5b_defconfig` |
| Board files | `buildroot-external/board/xunlong/orangepi5b` |
| SoC | Rockchip RK3588S (4x A76 + 4x A55, Mali G610) |
| U-Boot | mainline v2026.10, `orangepi-5-rk3588s_defconfig` + `uboot.config` fragment (5B device tree, sdhci on, no SPI image) |
| TF-A / OP-TEE | same as the 5 Plus |
| Linux | 7.3.3 (pinned), DTS `rockchip/rk3588s-orangepi-5b` |
| Kernel config | `orangepi5plus/armbian-kernel.config` + HAOS fragments + board `kernel.config` |
| Kernel patches | `orangepi5plus/patches/linux` (includes the Orange Pi 5/5B Type-C fix) |
| U-Boot patches | `orangepi5plus/patches/uboot` + `orangepi5b/patches/uboot` (adds `rk3588s-orangepi-5b-u-boot.dtsi`) |

The 5B is the Orange Pi 5 with on-board eMMC and a WiFi/BT module instead of
the SPI NOR flash and the M.2 slot. U-Boot upstream has no 5B defconfig, so the
Orange Pi 5 one is used with the 5B device tree. The added U-Boot dtsi uses the
RK3588S base and makes the SPL try the SD card first, then the eMMC.

## Hardware status

| Feature | Status | Notes |
|---|---|---|
| SD card boot | first image built 2026-11-23, testing | |
| eMMC boot | expected to work | sdhci enabled in U-Boot and Linux; flash the image to the eMMC (e.g. from an SD-booted system) |
| Gigabit Ethernet (RTL8211F on gmac1) | expected to work | stmmac/dwmac-rockchip + Realtek PHY are built in |
| Mali G610 GPU, video decode/encode | as on the 5 Plus | |
| WiFi / Bluetooth (on-board module) | not expected to work | the mainline 5B device tree does not describe the module |
| NVMe / M.2 | n/a | no M.2 slot on the 5B |
| OTA from the Home Assistant UI | no | unofficial build, update with RAUC |

Update this table as features are verified on hardware.

## Install

Flash `haos_orangepi5b-<version>.img.xz` to an SD card (or the eMMC). The
bootloader is in the image, so nothing else needs to be written. Serial console:
UART2 on the debug header, 1500000 8N1.

## Update

Same as the 5 Plus: `haos_orangepi5b-<version>.raucb` on a USB stick labelled
`CONFIG`, or `rauc install` from the host shell, then reboot.

## Build

```sh
scripts/update-board.sh -b orangepi5b
```

Source volume `haos-orangepi5b-src`. It shares the `haos-opi5plus-cache`
download and ccache volume with the 5 Plus (same `/build` paths, so ccache hits).
