#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# deploy-aperture-science.sh — Setup de dotfiles en aperture-science (RPi5)
#
# Clonar el repo primero (una sola vez, como root):
#   git clone https://github.com/themakunga/public-dotfiles.git /opt/public-dotfiles
#
# Parte desktop (Hyprland, waybar, wofi, wezterm) → ejecutar como wheatley:
#   sudo -u wheatley bash /opt/public-dotfiles/scripts/deploy-aperture-science.sh
#
# Parte glados (mascota, config, .env) → ejecutar como root:
#   sudo mkdir -p /opt/glados/config
#   sudo ln -s /opt/public-dotfiles/hypr/scripts/mascot.sh /opt/glados/mascot.sh
#   sudo ln -s /opt/public-dotfiles/agent /opt/glados/agent
#   sudo cp /opt/public-dotfiles/zeroclaw/config.aperture-science.yaml /opt/glados/config/config.yaml
#   sudo nano /opt/glados/config/.env   ← copiar desde zeroclaw/telegram.env.example
#   sudo chmod 600 /opt/glados/config/.env && sudo chown glados:glados /opt/glados/config/.env
#
# Qué hace este script (parte wheatley):
#   1. Symlinks de dotfiles → ~/.config/ (wheatley home: /opt/wheatley/)
#   2. Mascota GLaDOS → /opt/glados/mascot.sh (solo si /opt/glados existe)
#   3. Waybar scripts → permisos de ejecución
#   4. .env de zeroclaw (si no existe y /opt/glados accesible, guía interactiva)
#   5. Recarga servicios: waybar, zeroclaw-glados
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GLADOS_HOME="/opt/glados"
XDG_CONFIG="${HOME}/.config"

# ── Colores (TokyoNight Storm) ────────────────────────────────────────────────
GREEN='\033[38;2;158;206;106m'
YELLOW='\033[38;2;224;175;104m'
RED='\033[38;2;247;118;142m'
BLUE='\033[38;2;122;162;247m'
GRAY='\033[38;2;86;95;137m'
R='\033[0m'

step()  { printf "\n${BLUE}▸${R} %s\n" "$*"; }
ok()    { printf "  ${GREEN}✔${R} %s\n" "$*"; }
warn()  { printf "  ${YELLOW}⚠${R} %s\n" "$*"; }
fail()  { printf "  ${RED}✖${R} %s\n" "$*"; exit 1; }
info()  { printf "  ${GRAY}·${R} %s\n" "$*"; }

echo ""
printf "${BLUE}╔══════════════════════════════════════════╗${R}\n"
printf "${BLUE}║${R}  GLaDOS — aperture-science deployment    ${BLUE}║${R}\n"
printf "${BLUE}╚══════════════════════════════════════════╝${R}\n"

# ── 1. Symlinks de dotfiles ────────────────────────────────────────────────────
step "Configurando symlinks en ~/.config/"

symlink() {
    local src="$1" dst="$2"
    if [[ -L "$dst" ]]; then
        info "ya existe: $dst → $(readlink "$dst")"
    elif [[ -e "$dst" ]]; then
        warn "ya existe (no es symlink): $dst — omitido"
    else
        mkdir -p "$(dirname "$dst")"
        ln -s "$src" "$dst"
        ok "creado: $dst → $src"
    fi
}

symlink "${REPO_DIR}/hypr"      "${XDG_CONFIG}/hypr"
symlink "${REPO_DIR}/wofi"      "${XDG_CONFIG}/wofi"
symlink "${REPO_DIR}/waybar"    "${XDG_CONFIG}/waybar"
symlink "${REPO_DIR}/wezterm"   "${XDG_CONFIG}/wezterm"
symlink "${REPO_DIR}/fastfetch" "${XDG_CONFIG}/fastfetch"
symlink "${REPO_DIR}/btop"      "${XDG_CONFIG}/btop"
symlink "${REPO_DIR}/nvim"      "${XDG_CONFIG}/nvim"

# ── 2. Mascota GLaDOS ─────────────────────────────────────────────────────────
step "Configurando mascota GLaDOS"

MASCOT_SRC="${REPO_DIR}/hypr/scripts/mascot.sh"
MASCOT_DST="${GLADOS_HOME}/mascot.sh"

if [[ ! -d "${GLADOS_HOME}" ]]; then
    warn "/opt/glados no existe — la mascota no se puede instalar aquí"
    warn "Instala zeroclaw primero: sudo mkdir -p /opt/glados && sudo chown glados:glados /opt/glados"
else
    chmod +x "${MASCOT_SRC}"
    if [[ -L "${MASCOT_DST}" ]]; then
        info "ya existe: ${MASCOT_DST}"
    else
        ln -s "${MASCOT_SRC}" "${MASCOT_DST}"
        ok "symlink creado: ${MASCOT_DST} → ${MASCOT_SRC}"
    fi
fi

# Symlink de agent/ en /opt/glados
AGENT_DST="${GLADOS_HOME}/agent"
if [[ -d "${GLADOS_HOME}" && ! -e "${AGENT_DST}" ]]; then
    ln -s "${REPO_DIR}/agent" "${AGENT_DST}"
    ok "symlink creado: ${AGENT_DST} → ${REPO_DIR}/agent"
elif [[ -e "${AGENT_DST}" ]]; then
    info "ya existe: ${AGENT_DST}"
fi

# ── 3. Permisos waybar ────────────────────────────────────────────────────────
step "Configurando permisos de waybar scripts"
chmod +x "${REPO_DIR}/waybar/scripts/zeroclaw-status.sh"
ok "zeroclaw-status.sh ejecutable"

# ── 4. Zeroclaw .env ──────────────────────────────────────────────────────────
step "Verificando secrets de zeroclaw"

ENV_FILE="${GLADOS_HOME}/config/.env"

if [[ -f "${ENV_FILE}" ]]; then
    ok "ya existe: ${ENV_FILE}"
    info "Para editar: nano ${ENV_FILE}"
else
    if [[ ! -d "${GLADOS_HOME}" ]]; then
        warn "/opt/glados no existe — omitiendo .env"
    else
        mkdir -p "${GLADOS_HOME}/config"

        warn ".env no existe. Creando desde template..."
        printf "\n"
        printf "  ${YELLOW}Necesito algunos datos para el canal de Telegram:${R}\n\n"

        read -rp "  Token del bot de Telegram (BotFather): " BOT_TOKEN
        read -rp "  Chat ID de Nicolas (@TheMakunga): " CHAT_NICOLAS
        read -rp "  Chat ID de Meddy (@Mighty_Meddy, o Enter para omitir): " CHAT_MEDDY

        cat > "${ENV_FILE}" <<EOF
# GLaDOS — Secrets (NO incluir en git)
# Generado por deploy-aperture-science.sh

TELEGRAM_BOT_TOKEN=${BOT_TOKEN}
TELEGRAM_CHAT_NICOLAS=${CHAT_NICOLAS}
TELEGRAM_CHAT_MEDDY=${CHAT_MEDDY:-}
EOF
        chmod 600 "${ENV_FILE}"
        ok "creado: ${ENV_FILE} (modo 600)"

        # Copiar config de zeroclaw
        ZEROCLAW_CONFIG_DST="${GLADOS_HOME}/config/config.yaml"
        if [[ ! -f "${ZEROCLAW_CONFIG_DST}" ]]; then
            cp "${REPO_DIR}/zeroclaw/config.aperture-science.yaml" "${ZEROCLAW_CONFIG_DST}"
            ok "config copiada: ${ZEROCLAW_CONFIG_DST}"
        fi
    fi
fi

# ── 5. Verificar token de Telegram ────────────────────────────────────────────
step "Verificando bot de Telegram"

if [[ -f "${ENV_FILE}" ]]; then
    # shellcheck disable=SC1090
    source "${ENV_FILE}"
    if [[ -n "${TELEGRAM_BOT_TOKEN:-}" && "${TELEGRAM_BOT_TOKEN}" != "<"* ]]; then
        response=$(curl -sf "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe" 2>/dev/null || echo "")
        if echo "$response" | grep -q '"ok":true'; then
            bot_name=$(echo "$response" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
            ok "Bot conectado: @${bot_name}"
        else
            warn "No se pudo conectar con el token — verificar en ${ENV_FILE}"
        fi
    else
        warn "Token no configurado en ${ENV_FILE}"
    fi
fi

# ── 6. Recargar servicios ─────────────────────────────────────────────────────
step "Recargando servicios"

# Waybar
if pgrep -x waybar &>/dev/null; then
    pkill -SIGUSR2 waybar 2>/dev/null && ok "waybar recargado (SIGUSR2)" || warn "waybar: no se pudo recargar"
else
    info "waybar no está corriendo — se iniciará con Hyprland"
fi

# Zeroclaw
if systemctl is-active --quiet zeroclaw-glados 2>/dev/null; then
    systemctl restart zeroclaw-glados && ok "zeroclaw-glados reiniciado" || warn "zeroclaw-glados: no se pudo reiniciar"
else
    info "zeroclaw-glados no está activo — iniciar con: sudo systemctl start zeroclaw-glados"
fi

# ── Resumen ───────────────────────────────────────────────────────────────────
printf "\n${GREEN}╔══════════════════════════════════════════╗${R}\n"
printf "${GREEN}║${R}  Deploy completado.                       ${GREEN}║${R}\n"
printf "${GREEN}╚══════════════════════════════════════════╝${R}\n\n"
printf "  ${GRAY}Para obtener chat IDs de Telegram:${R}\n"
printf "  ${BLUE}curl https://api.telegram.org/bot\${TELEGRAM_BOT_TOKEN}/getUpdates${R}\n"
printf "  ${GRAY}(envía un mensaje al bot primero desde cada cuenta)${R}\n\n"
