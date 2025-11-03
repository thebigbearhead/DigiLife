#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/.env-rpi-ops" 2>/dev/null || true
DAYS="${JOURNAL_MAX_DAYS:-7}"
sudo journalctl --vacuum-time="${DAYS}d"
echo "Journal vacuumed to ${DAYS} days"
