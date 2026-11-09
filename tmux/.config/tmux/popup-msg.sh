#!/usr/bin/env bash
# popup-msg.sh — show a message in a centered floating popup (replaces display-message).
# Usage: popup-msg.sh <message> [seconds]   (any key dismisses early)
MSG="$1"; SECS="${2:-2}"
W=$(( ${#MSG} + 6 )); [ "$W" -lt 24 ] && W=24
tmux display-popup -E -b rounded -s "fg=#86e1fc,bg=#444a73" -S "fg=#9ece6a" \
  -w "$W" -h 3 -x C -y C \
  "printf '\n  %s' \"\$1\"; read -rsn1 -t $SECS" _ "$MSG"
