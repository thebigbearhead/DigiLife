#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/.env-rpi-ops" 2>/dev/null || true

URL="${1:-}"
TIMEOUT="${CHECKWEB_TIMEOUT:-10}"
[[ -z "$URL" ]] && { echo "Usage: $0 <url>"; exit 2; }

status=$(curl -k -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" "$URL" || echo "000")
case "$status" in
  2*|3*) verdict="✅ OK ($status)";;
  000)   verdict="🛑 DOWN (timeout/fail)";;
  *)     verdict="⚠️ HTTP $status";;
esac

msg="Check: $URL
Result: $verdict
Time: $(date -Is)"
"$ROOT_DIR/scripts/notify.sh" "$msg" "Web Check"
echo "$verdict"
