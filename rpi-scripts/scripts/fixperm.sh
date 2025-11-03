#!/usr/bin/env bash
# ใช้: sudo fixperm.sh /path user:group 755
set -euo pipefail
TARGET="${1:-}"
OWNER="${2:-$(id -un):$(id -gn)}"
MODE="${3:-755}"
[[ -z "$TARGET" ]] && { echo "Usage: sudo $0 <path> [owner:group] [mode]"; exit 2; }
chown -R "$OWNER" "$TARGET"
find "$TARGET" -type d -print0 | xargs -0 chmod "$MODE"
find "$TARGET" -type f -print0 | xargs -0 chmod "${MODE}"; echo "Done."
