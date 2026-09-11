#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# zeroclaw-status.sh — estado del servicio zeroclaw para Waybar
# Output: JSON con text, class y tooltip (return-type: json)
# ─────────────────────────────────────────────────────────────────────────────

status=$(systemctl is-active zeroclaw 2>/dev/null || echo "inactive")

case "$status" in
    active)
        echo '{"text":"⬡ GLaDOS","class":"active","tooltip":"Zeroclaw operacional — Sistema nominal."}'
        ;;
    failed)
        echo '{"text":"⬡ GLaDOS","class":"failed","tooltip":"Zeroclaw: error detectado. Revisar logs."}'
        ;;
    activating)
        echo '{"text":"⬡ GLaDOS","class":"activating","tooltip":"Zeroclaw inicializando..."}'
        ;;
    *)
        echo '{"text":"⬡ GLaDOS","class":"inactive","tooltip":"Zeroclaw offline — Modo bajo consumo."}'
        ;;
esac
