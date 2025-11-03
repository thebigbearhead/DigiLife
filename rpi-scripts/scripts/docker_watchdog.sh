#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/.env-rpi-ops" 2>/dev/null || true
ROOT="${DOCKER_ROOT:-/home/raspi/docker}"

broken=()
while IFS= read -r -d '' yml; do
  dir=$(dirname "$yml")
  if ! (cd "$dir" && docker compose ps --status running | grep -q .); then
    (cd "$dir" && docker compose up -d || true)
    broken+=("$dir")
  fi
done < <(find "$ROOT" -maxdepth 2 -type f \( -name "compose.yml" -o -name "docker-compose.yml" \) -print0)

if ((${#broken[@]})); then
  "$ROOT_DIR/scripts/notify.sh" "Restarted stacks:\n- ${broken[*]}" "Docker Watchdog"
fi
