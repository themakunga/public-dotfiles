#!/usr/bin/env bash
# Deploy WeeChat config on any host.
# Sensitive:     irc.conf  → decrypted from SOPS
# Non-sensitive: weechat.conf → symlinked from this repo
set -e

SECRETS_DIR="${SECRETS_DIR:-$HOME/Projects/personal/secrets}"
WEECHAT_HOME="${WEECHAT_HOME:-$HOME/.config/weechat}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$WEECHAT_HOME"

echo "[weechat] Deploying irc.conf from SOPS..."
sops -d "$SECRETS_DIR/shared-conf/weechat/irc.conf" > "$WEECHAT_HOME/irc.conf"

echo "[weechat] Linking weechat.conf..."
ln -sf "$SCRIPT_DIR/weechat.conf" "$WEECHAT_HOME/weechat.conf"

echo "[weechat] Done. Run: weechat"
