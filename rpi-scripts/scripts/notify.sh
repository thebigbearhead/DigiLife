#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/.env-rpi-ops" 2>/dev/null || true

msg="${1:-}"
title="${2:-"rpi-ops"}"
if [[ -n "${NTFY_URL:-}" ]]; then
  curl -fsS -X POST -H "Title: $title" -H "Tags: robot" -d "$msg" "$NTFY_URL" || true
fi
echo "[$title] $msg"
