alias drun="docker compose -f compose.yml run --rm"
alias nixedit="cd ~/.nix-systems/ && nvim"
alias dotedit="cd ~/.public-dotfiles/ && nvim"
alias sdotedit="cd ~/.private-dotfiles/ && nvim"
alias secretsedit="cd ~/.secrets/ && nvim"
alias chat="cd ~/Downloads/ && nchat"


# =========================================================
# GLaDOS & Local AI Management
# =========================================================

# --- Control de Servicios (launchd) ---
alias glados-start='sudo launchctl start system/org.nixos.zeroclaw-glados 2>/dev/null || sudo launchctl start system/zeroclaw-glados'
alias glados-stop='sudo launchctl stop system/org.nixos.zeroclaw-glados 2>/dev/null || sudo launchctl stop system/zeroclaw-glados'
alias glados-restart='sudo launchctl kickstart -k system/org.nixos.zeroclaw-glados 2>/dev/null || sudo launchctl kickstart -k system/zeroclaw-glados'

alias ai-start='sudo launchctl start system/org.nixos.ollama-glados 2>/dev/null || sudo launchctl start system/ollama-glados'
alias ai-stop='sudo launchctl stop system/org.nixos.ollama-glados 2>/dev/null || sudo launchctl stop system/ollama-glados'
alias ai-restart='sudo launchctl kickstart -k system/org.nixos.ollama-glados 2>/dev/null || sudo launchctl kickstart -k system/ollama-glados'

# --- Ejecución e Interacción con Zeroclaw ---
# Corre cualquier subcomando de Zeroclaw bajo la identidad y jaula de GLaDOS
alias glados='sudo -u glados env HOME=/opt/glados /opt/glados/bin/zeroclaw'
alias zc='glados' # Atajo ultra corto

# --- Navegación e Inspección ---
alias cd-glados='cd /opt/glados'
alias glados-status='ps aux | grep -E "ollama|zeroclaw" | grep -v grep'

# --- Lectura de Logs ---
alias glados-logs='tail -f /opt/glados/zeroclaw.out.log /opt/glados/zeroclaw.err.log'
alias ai-logs='tail -f /opt/glados/ollama.out.log /opt/glados/ollama.err.log'
alias ai-logs-all='tail -f /opt/glados/*.log'
