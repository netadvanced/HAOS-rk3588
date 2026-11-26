#!/usr/bin/env bash
# Make sure a Docker build volume signs RAUC bundles with the fork's key.
#
# Installed boards only accept .raucb bundles signed by this key (its cert is
# appended to /etc/rauc/keyring.pem at build time). If /build/key.pem is missing,
# buildroot-external/scripts/rauc.sh silently generates a new self-signed key and
# every installed board would reject the resulting updates. So before any build:
#   - key present and matching the expected certificate -> OK
#   - key missing -> restore key.pem + cert.pem from 1Password into the volume
#   - a different key present -> stop, never overwrite it silently
#
# Usage: scripts/ensure-signing-key.sh <src-volume>   (e.g. haos-orangepi5b-src)
set -euo pipefail

VOL="${1:?usage: $0 <src-volume>}"
OP_ITEM="${OP_ITEM:-op://Private/HAOS RK3588 RAUC signing key}"
# SHA256 fingerprint of cert.pem ("HassOS Self-signed Development Certificate",
# created 2026-10-04, expires 2036-10-01). Public information, safe to pin here.
EXPECTED_FP="FF:2F:57:C8:86:1F:11:BE:38:12:6D:9B:E0:D0:DF:8B:9A:A3:D1:D9:34:B0:5A:C1:B6:DA:30:89:F2:ED:F4:3A"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
in_vol() { docker run --rm -i -v "$VOL":/build alpine sh -c "$1"; }

docker volume inspect "$VOL" >/dev/null 2>&1 || die "volume $VOL does not exist"

cert_fp() { openssl x509 -noout -fingerprint -sha256 2>/dev/null | cut -d= -f2; }
pub_hash() { shasum -a 256 | cut -d' ' -f1; }

vol_fp="$(in_vol '[ -f /build/cert.pem ] && cat /build/cert.pem || true' | cert_fp || true)"
has_key="$(in_vol '[ -s /build/key.pem ] && echo yes || echo no')"

if [ -z "$vol_fp" ] && [ "$has_key" = no ]; then
    command -v op >/dev/null || die "1Password CLI (op) not installed, cannot restore the signing key"
    echo "Restoring the RAUC signing key into $VOL from 1Password"
    op read "$OP_ITEM/cert.pem" | in_vol 'cat > /build/cert.pem; chown 1000:1000 /build/cert.pem; chmod 644 /build/cert.pem'
    op read "$OP_ITEM/key.pem" | in_vol 'umask 077; cat > /build/key.pem; chown 1000:1000 /build/key.pem; chmod 600 /build/key.pem'
    vol_fp="$(in_vol 'cat /build/cert.pem' | cert_fp)"
elif [ -z "$vol_fp" ] || [ "$has_key" = no ]; then
    die "$VOL has only one of key.pem/cert.pem; fix by hand (restore both from 1Password: $OP_ITEM)"
fi

[ "$vol_fp" = "$EXPECTED_FP" ] ||
    die "$VOL signs with a different certificate ($vol_fp), expected $EXPECTED_FP. Bundles from it would be rejected by installed boards."

# The private key must belong to that certificate
[ "$(in_vol 'cat /build/cert.pem' | openssl x509 -noout -pubkey | pub_hash)" = \
  "$(in_vol 'cat /build/key.pem' | openssl pkey -pubout | pub_hash)" ] ||
    die "/build/key.pem in $VOL does not match /build/cert.pem"

echo "RAUC signing key OK in $VOL ($EXPECTED_FP)"
