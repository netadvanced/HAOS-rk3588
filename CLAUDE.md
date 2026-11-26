# HAOS-rk3588 (netadvanced fork)

Home Assistant OS for RK3588 boards on top of nyok92/HAOS-rock5b. Board branches:
`orangepi5plus`, `orangepi5b` (on top of `orangepi5plus`), `*-dev` variants with
upstream merged in. Board docs: `Documentation/boards/xunlong/*.md`.

## Building — mandatory rules

- **RAUC signing key before every build.** Installed boards only accept `.raucb`
  bundles signed with the fork's key; if `/build/key.pem` is missing the build
  silently creates a new key and the bundles are useless. Before starting any
  build container — including ad-hoc `docker run … make <board>` /
  `make linux-reconfigure` / incremental rebuilds — run:

      scripts/ensure-signing-key.sh <src-volume>

  It restores the key from 1Password (Private vault, item
  "HAOS RK3588 RAUC signing key") when missing and refuses a volume with a
  different key. `scripts/update-board.sh` does this automatically and also
  verifies the finished bundle with `rauc info --keyring /build/cert.pem`.
- Prefer `scripts/update-board.sh -b <board>`; it syncs the branch into the
  volume, handles the buildroot submodule and Go bumps, and copies artifacts to
  `~/Projects/HAOS-images`.
- Build in a fresh container each time (`docker start` on an old one fails in
  entry.sh). Volumes: `haos-opi5plus-src` / `haos-orangepi5b-src` (+ `-dev-src`),
  shared download/ccache volume `haos-opi5plus-cache`.

## Boards

- Never `dd` an image onto the eMMC while an OS runs from it; never boot HAOS
  from SD and eMMC at the same time (duplicate labels/PARTUUIDs). See the 5B doc.
- Update installed boards with `rauc install <bundle>.raucb` (A/B slots with
  boot-count fallback), not by reflashing.
