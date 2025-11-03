#!/usr/bin/env bash
set -euo pipefail
DEV="${1:-/dev/mmcblk0}"
OUT="${2:-/mnt/exthddbig/snapshots}"
mkdir -p "$OUT"
ts=$(date +%Y%m%d-%H%M%S)
sudo dd if="$DEV" bs=4M status=progress | gzip -c > "$OUT/rpi-sd-$ts.img.gz"
sync
echo "Snapshot saved to $OUT/rpi-sd-$ts.img.gz"
