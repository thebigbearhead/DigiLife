#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/.env-rpi-ops" 2>/dev/null || true
WARN="${TEMP_WARN:-75}"

get_temp() {
  vcgencmd measure_temp 2>/dev/null | sed 's/[^0-9\.]//g'
}

t=$(get_temp || echo 0)
if [[ "$t" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( ${t%.*} >= WARN )); then
  "$ROOT_DIR/scripts/notify.sh" "Temp ${t}°C >= ${WARN}°C" "Temp Alert"
fi
echo "Temp: ${t}°C"
