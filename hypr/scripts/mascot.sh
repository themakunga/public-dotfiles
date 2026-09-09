#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# mascot.sh — GLaDOS terminal mascot para aperture-science
#
# Muestra ASCII art de Aperture Science en una ventana flotante de WezTerm.
# Reacciona al estado del servicio systemd zeroclaw-glados con colores
# TokyoNight Storm.
#
# Identificación de ventana: título "glados-mascot"
# Hyprland windowrule: title:^(glados-mascot)$ → float, pin, nofocus
#
# Despliegue: symlink a /opt/glados/mascot.sh
#   ln -s /opt/glados/public-dotfiles/hypr/scripts/mascot.sh /opt/glados/mascot.sh
# ─────────────────────────────────────────────────────────────────────────────

# ── Título de ventana (usado por Hyprland windowrules) ────────────────────────
printf '\033]0;glados-mascot\007'

# ── TokyoNight Storm — ANSI true color ───────────────────────────────────────
R='\033[0m'                        # reset
GREEN='\033[38;2;158;206;106m'     # #9ece6a — zeroclaw activo
RED='\033[38;2;247;118;142m'       # #f7768e — zeroclaw fallido
GRAY='\033[38;2;86;95;137m'        # #565f89 — zeroclaw offline
YELLOW='\033[38;2;224;175;104m'    # #e0af68 — inicializando
BLUE='\033[38;2;122;162;247m'      # #7aa2f7 — acento
DIM='\033[38;2;65;72;104m'         # #414868 — bordes dim

# ── Render ────────────────────────────────────────────────────────────────────
render() {
    local color="$1"
    local label="$2"
    local icon="$3"

    clear
    printf "\n"
    printf "  ${DIM}╔══════════════════════════════════════╗${R}\n"
    printf "  ${DIM}║${R}  ${BLUE}▸ A P E R T U R E  S C I E N C E${R}     ${DIM}║${R}\n"
    printf "  ${DIM}╠══════════════════════════════════════╣${R}\n"
    printf "  ${DIM}║${R}                                      ${DIM}║${R}\n"
    printf "  ${DIM}║${R}     ${color}   ██████╗ ██╗      █████╗    ${R}  ${DIM}║${R}\n"
    printf "  ${DIM}║${R}     ${color}  ██╔════╝ ██║     ██╔══██╗   ${R}  ${DIM}║${R}\n"
    printf "  ${DIM}║${R}     ${color}  ██║  ███╗██║     ███████║   ${R}  ${DIM}║${R}\n"
    printf "  ${DIM}║${R}     ${color}  ██║   ██║██║     ██╔══██║   ${R}  ${DIM}║${R}\n"
    printf "  ${DIM}║${R}     ${color}  ╚██████╔╝███████╗██║  ██║   ${R}  ${DIM}║${R}\n"
    printf "  ${DIM}║${R}     ${color}   ╚═════╝ ╚══════╝╚═╝  ╚═╝   ${R}  ${DIM}║${R}\n"
    printf "  ${DIM}║${R}                                      ${DIM}║${R}\n"
    printf "  ${DIM}╠══════════════════════════════════════╣${R}\n"
    printf "  ${DIM}║${R}  ${color}${icon} zeroclaw ▸ %-22s${R}  ${DIM}║${R}\n" "${label}"
    printf "  ${DIM}╚══════════════════════════════════════╝${R}\n"
    printf "\n"
}

# ── Main loop ─────────────────────────────────────────────────────────────────
while true; do
    status=$(systemctl is-active zeroclaw-glados 2>/dev/null || echo "inactive")

    case "$status" in
        active)
            render "$GREEN" "nominal" "●"
            ;;
        failed)
            render "$RED" "error detectado" "✖"
            ;;
        activating)
            render "$YELLOW" "inicializando..." "◌"
            ;;
        deactivating)
            render "$YELLOW" "deteniendo..." "◌"
            ;;
        *)
            render "$GRAY" "offline" "○"
            ;;
    esac

    sleep 2
done
