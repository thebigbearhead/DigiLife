#!/usr/bin/env bash
set -euo pipefail
docker system prune -af --volumes
echo "Docker cleaned at $(date -Is)"
