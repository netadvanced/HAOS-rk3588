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
| SD card boot | works | |
| eMMC boot | works | tested 2026-11-26 on a 16 GB / 128 GB eMMC board; first boot grows the data partition to the full eMMC |
| Gigabit Ethernet (RTL8211F on gmac1) | works | 1 Gbps link, DHCP |
| HDMI console, status LED | works | display and LED drivers load as modules once userspace starts, so the screen stays dark for the first ~20 s |
| Mali G610 GPU, video decode/encode, NPU | drivers load | panthor, rkvdec, hantro, rkvenc, rocket probe fine; not exercised yet |
| USB 3.0 ports (blue) | works | |
| USB 2.0 port (white) and USB-C | works | the white port is wired to the USB-C controller (`usb_host0_xhci`); the DT sets `role-switch-default-mode = "host"` so it is a host when nothing is plugged into USB-C |
| WiFi (AP6275P / BCM43752, PCIe) | works | 2.4 + 5 GHz; DT patch adds it on `pcie2x1l2`, firmware `brcmfmac43752-pcie.*` from armbian/firmware in the board overlay |
| Bluetooth (BCM4362A2, UART9) | works | controller up with `BCM4362A2.hcd`; check pairing in Home Assistant |
| NVMe / M.2 | n/a | no M.2 slot on the 5B |
| OTA from the Home Assistant UI | no | unofficial build, update with `rauc install` (tested: A→B update, 3 warm reboots OK) |

Update this table as features are verified on hardware.

## Install

Flash `haos_orangepi5b-<version>.img.xz` to an SD card or the eMMC. The
bootloader is in the image (32 KiB offset), so nothing else needs to be
written. Serial console: UART2 on the debug header, 1500000 8N1.

Installing to the eMMC:

- Never write the image over the system that is running from the eMMC (e.g.
  Armbian): its page cache and journal keep writing to the old filesystem and
  corrupt the new image (we lost the boot partition that way). Boot HAOS from an
  SD card first, then write the eMMC from there, e.g.
  `curl -sf http://<host>/haos_orangepi5b.img | dd of=/dev/mmcblk0 bs=4M`.
- Do not boot with HAOS on both the SD card and the eMMC: both use the same
  partition labels and PARTUUIDs, so systemd mixes overlay/data partitions from
  the two disks, haos-expand may grow the wrong one and haos-data-disk-detach
  renames the other `hassos-data-dis`. Remove the card once the eMMC is written.
- On macOS, an ext4 driver such as Paragon ExtFS auto-mounts the freshly
  flashed card's ext4 partitions and leaves the overlay journal dirty; the next
  boot can then fail to mount the overlay and NetworkManager, SSH and the CLI do
  not start. Eject the card right after flashing or disable auto-mount.
- The kernel warns that the alternate GPT header is not at the end of the disk
  on first boot; haos-expand moves it, do not fix it by hand.

## Update

RAUC 1.13 needs `patches/rauc/0002-dm-accept-extra-fields-in-the-dm-verity-status-line.patch`
on Linux 7.x kernels, otherwise every install fails with
"Unexpected dm-verity status 'V -'". Images built before that patch cannot
install bundles themselves: run the fixed `rauc` binary from the new build once
(systemd drop-in in `/run` pointing `rauc.service` at it), install, reboot.

Same as the 5 Plus: `haos_orangepi5b-<version>.raucb` on a USB stick labelled
`CONFIG`, or `rauc install` from the host shell, then reboot.

## Build

```sh
scripts/update-board.sh -b orangepi5b
```

Source volume `haos-orangepi5b-src`. It shares the `haos-opi5plus-cache`
download and ccache volume with the 5 Plus (same `/build` paths, so ccache hits).
