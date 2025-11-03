#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/.env-rpi-ops" 2>/dev/null || true

SRC="${BACKUP_SRC:?BACKUP_SRC not set}"
DST="${BACKUP_DST:?BACKUP_DST not set}"
EXC="${BACKUP_EXCLUDES:-}"

mkdir -p "$DST"
rsync -avh --delete $EXC --info=progress2 "$SRC"/ "$DST"/
code=$?
msg="rsync backup: $SRC -> $DST
Exit: $code
Time: $(date -Is)"
"$ROOT_DIR/scripts/notify.sh" "$msg" "Backup"
exit $code
