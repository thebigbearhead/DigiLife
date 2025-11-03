#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/.env-rpi-ops" 2>/dev/null || true

host=$(hostname)
uptime_now=$(uptime -p || true)
temp=$(vcgencmd measure_temp 2>/dev/null | sed 's/[^0-9\.]//g' || echo "?")
loadavg=$(cut -d' ' -f1-3 /proc/loadavg)
mem_free=$(free -h | awk '/Mem:/{print $7 " free"}')
disk_root=$(df -h / | awk 'END{print $5 " used"}')
ip=$(hostname -I 2>/dev/null | awk '{print $1}')
docker_count=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
msg="Host: $host
Uptime: $uptime_now
Temp: ${temp}°C
Load: $loadavg
Mem: $mem_free
Disk(/): $disk_root
IP: $ip
Docker running: $docker_count"
"$ROOT_DIR/scripts/notify.sh" "$msg" "RPi Health"
