#!/bin/bash
# changepo.sh — auto version with color + confirm + logging
# ใช้: changepo [--no-color] <target1> [target2 ...]
# ค่าพื้นฐาน: owner/group = ผู้ใช้ปัจจุบัน, perm=755, log=/var/log/changepo.log

set -euo pipefail

USER_NAME="$(whoami)"
GROUP_NAME="$(id -gn)"
PERM="755"
LOG_FILE="/var/log/changepo.log"

# ---------- Color setup ----------
USE_COLOR=1
for arg in "$@"; do [[ "$arg" == "--no-color" ]] && USE_COLOR=0; done
[[ -t 1 ]] || USE_COLOR=0                 # not a TTY → no color
[[ "${NO_COLOR:-}" != "" ]] && USE_COLOR=0

if [[ $USE_COLOR -eq 1 ]]; then
  BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'
  RED='\033[31m'; GREEN='\033[32m'; YELLOW='\033[33m'; BLUE='\033[34m'; MAGENTA='\033[35m'; CYAN='\033[36m'
  ICON_INFO="🔧"; ICON_OK="✅"; ICON_WARN="⚠️ "; ICON_SKIP="⏭️"; ICON_FILE="📂"; ICON_LOG="🪶"
else
  BOLD=''; DIM=''; RESET=''
  RED=''; GREEN=''; YELLOW=''; BLUE=''; MAGENTA=''; CYAN=''
  ICON_INFO='[i]'; ICON_OK='[OK]'; ICON_WARN='[!]' ; ICON_SKIP='[>>]'; ICON_FILE='[FILE]'; ICON_LOG='[LOG]'
fi

# ---------- Args ----------
# กรอง --no-color ออกจากรายการ target
TARGETS=()
for a in "$@"; do [[ "$a" == "--no-color" ]] && continue; TARGETS+=("$a"); done

if [[ ${#TARGETS[@]} -lt 1 ]]; then
  printf "${RED}❌ Usage:${RESET} %s <target1> [target2 ...]\n" "$(basename "$0")"
  exit 1
fi

# ---------- Log prep ----------
if [ ! -w "$(dirname "$LOG_FILE")" ]; then
  printf "${DIM}%s Preparing log at %s (sudo)…${RESET}\n" "$ICON_LOG" "$LOG_FILE"
  sudo mkdir -p "$(dirname "$LOG_FILE")"
  sudo touch "$LOG_FILE"
  sudo chmod 666 "$LOG_FILE"
fi

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

# ---------- Run ----------
for TARGET in "${TARGETS[@]}"; do
  if [ ! -e "$TARGET" ]; then
    printf "${YELLOW}%s Target not found:${RESET} %s (skipped)\n" "$ICON_WARN" "$TARGET"
    continue
  fi

  # สรุปก่อนรัน
  printf "\n${CYAN}${BOLD}%s Change${RESET} %s ${DIM}→${RESET} ${MAGENTA}%s:%s${RESET} ${DIM}(%s)${RESET}\n" \
    "$ICON_FILE" "$TARGET" "$USER_NAME" "$GROUP_NAME" "$PERM"

  # ยืนยัน
  read -p "$(printf "${YELLOW}${BOLD}%sProceed? (y/n): ${RESET}" "$ICON_WARN")" CONFIRM
  if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    printf "${DIM}%s Skipped:${RESET} %s\n" "$ICON_SKIP" "$TARGET"
    continue
  fi

  # ทำงานจริง + log
  printf "${DIM}%s Applying…${RESET}\n" "$ICON_INFO"
  echo "$(timestamp) — START: $TARGET ($USER_NAME:$GROUP_NAME $PERM)" | sudo tee -a "$LOG_FILE" >/dev/null
  sudo chown -R "$USER_NAME:$GROUP_NAME" "$TARGET"
  sudo chmod -R "$PERM" "$TARGET"
  echo "$(timestamp) — DONE:  $TARGET ✅" | sudo tee -a "$LOG_FILE" >/dev/null

  printf "${GREEN}%s Applied successfully:${RESET} %s\n" "$ICON_OK" "$TARGET"
done

printf "\n${DIM}%s Log saved to%s %s${RESET}\n" "$ICON_LOG" ":" "$LOG_FILE"
