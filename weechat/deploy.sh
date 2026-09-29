#!/usr/bin/env bash
# Public UI + private Halloy connections. Close WeeChat before deploying.
set -euo pipefail
SECRETS_DIR="${SECRETS_DIR:-$HOME/Projects/personal/secrets}"
WEECHAT_HOME="${WEECHAT_HOME:-$HOME/.config/weechat}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec "${PYTHON:-python3}" "$SCRIPT_DIR/sync-halloy.py" \
  "$SECRETS_DIR/shared-conf/halloy/config.toml" "$WEECHAT_HOME"
