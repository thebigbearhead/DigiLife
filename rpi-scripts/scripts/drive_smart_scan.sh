#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/.env-rpi-ops" 2>/dev/null || true

disks=${SMART_DISKS:-}
[[ -z "$disks" ]] && { echo "No SMART_DISKS set"; exit 0; }

out=""
for d in $disks; do
  if smartctl -H "$d" &>/dev/null; then
    health=$(sudo smartctl -H "$d" | awk -F: '/overall-health/{gsub(/ /,"",$2);print $2}')
    out+="$d: $health"$'\n'
  else
    out+="$d: smartctl not supported or permission issue"$'\n'
  fi
done

"$ROOT_DIR/scripts/notify.sh" "$out" "SMART Scan"
echo "$out"
