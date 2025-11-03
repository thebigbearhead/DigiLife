#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[rpi-ops] Installing scripts to /usr/local/bin ..."
sudo mkdir -p /usr/local/bin
for f in "$ROOT_DIR"/scripts/*.sh; do
  sudo install -m 0755 "$f" /usr/local/bin/$(basename "$f")
done

echo "[rpi-ops] Installing systemd units ..."
sudo mkdir -p /etc/systemd/system
sudo cp "$ROOT_DIR"/systemd/*.service /etc/systemd/system/
sudo cp "$ROOT_DIR"/systemd/*.timer   /etc/systemd/system/

# Ensure config is available at /opt/rpi-ops
sudo mkdir -p /opt/rpi-ops
if [[ ! -f /opt/rpi-ops/.env-rpi-ops ]]; then
  sudo cp "$ROOT_DIR/.env-rpi-ops" /opt/rpi-ops/.env-rpi-ops
fi

sudo systemctl daemon-reload

# Enable baseline timers
for t in rpi-health.timer backup-rsync.timer docker-clean.timer docker-watchdog.timer smart-scan.timer temp-alert.timer journal-trim.timer; do
  sudo systemctl enable --now "$t"
done

echo "[rpi-ops] Done. Edit /opt/rpi-ops/.env-rpi-ops then: sudo systemctl restart backup-rsync.timer (etc.)"
