#!/usr/bin/env bash
# yank-flash.sh — visual yank indicator for tmux copy mode (imitates nvim's TextYankPost flash)
# Usage: yank-flash.sh <pane_id> <copy-mode-vi action>
#   Actions: copy-selection-and-cancel | copy-line
#
# Tokyo Night Storm palette (hardcoded — not available in shell env)
NORMAL_MODE_STYLE="fg=#82aaff,bg=#444a73,bold"
FLASH_STYLE="fg=#1a1b26,bg=#e0af68,bold"   # yellow flash, like nvim's IncSearch

PANE="$1"
ACTION="${2:-copy-selection-and-cancel}"

tmux set -g mode-style "$FLASH_STYLE"
sleep 0.15
tmux send-keys -t "$PANE" -X "$ACTION"
tmux set -g mode-style "$NORMAL_MODE_STYLE"
