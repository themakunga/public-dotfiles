#!/usr/bin/env bash
# check.sh — Verificación funcional de Hermes + Obsidian en aperture-science
# Ejecutar como usuario hermes: bash ~/.public-dotfiles/hermes/check.sh
set -euo pipefail

pass() { printf '\033[32m✓\033[0m %s\n' "$1"; }
fail() { printf '\033[31m✗\033[0m %s\n' "$1" >&2; FAILED=1; }
FAILED=0

echo "=== Verificación Hermes + Obsidian ==="
echo ""

# ── 1. Podman rootless ────────────────────────────────────────────────
if podman info --format '{{.Host.Security.Rootless}}' 2>/dev/null | grep -q true; then
  pass "Podman rootless"
else
  fail "Podman NO es rootless (¿estás ejecutando como hermes?)"
fi

# ── 2. Servicio activo ────────────────────────────────────────────────
if systemctl --user is-active hermes.service > /dev/null 2>&1; then
  pass "hermes.service activo"
else
  fail "hermes.service no está activo — ejecuta: systemctl --user start hermes.service"
fi

# ── 3. Contenedor corriendo ───────────────────────────────────────────
if podman ps --format '{{.Names}}' 2>/dev/null | grep -q '^hermes$'; then
  pass "Contenedor 'hermes' en ejecución"
else
  fail "Contenedor 'hermes' no encontrado en podman ps"
fi

# ── 4. Sin privilegios: no hay mounts privilegiados ───────────────────
PRIVILEGED=$(podman inspect hermes --format '{{.HostConfig.Privileged}}' 2>/dev/null || echo "error")
if [ "$PRIVILEGED" = "false" ]; then
  pass "Contenedor no privilegiado"
else
  fail "Contenedor privilegiado o no inspeccionable (valor: $PRIVILEGED)"
fi

# ── 5. Sin sockets de administración expuestos ─────────────────────────
DOCKER_SOCK=0
PODMAN_SOCK=0
[ -S /var/run/docker.sock ] && DOCKER_SOCK=1
[ -S /run/podman/podman.sock ] && PODMAN_SOCK=1
if [ $DOCKER_SOCK -eq 0 ] && [ $PODMAN_SOCK -eq 0 ]; then
  pass "Sin sockets Docker/Podman de administración en el host"
else
  fail "Socket de administración detectado (docker=$DOCKER_SOCK podman=$PODMAN_SOCK)"
fi

# ── 6. Vault escribible ────────────────────────────────────────────────
VAULT_DIR="$HOME/vault"
if TMP=$(mktemp "${VAULT_DIR}/.check-XXXXXX" 2>/dev/null); then
  rm -f "$TMP"
  pass "Vault escribible ($VAULT_DIR)"
else
  fail "Vault NO escribible ($VAULT_DIR)"
fi

# ── 7. obsidian help dentro del contenedor ────────────────────────────
if podman exec hermes obsidian help > /dev/null 2>&1; then
  pass "obsidian help OK"
else
  fail "obsidian help falló — ¿está /usr/local/bin/obsidian en el contenedor?"
fi

# ── 8. obsidian vault=Notes files (requiere Obsidian abierto y vault registrado) ──
if podman exec hermes obsidian vault=Notes files > /dev/null 2>&1; then
  pass "obsidian vault=Notes files OK"
else
  fail "obsidian vault=Notes files falló — abre Obsidian por VNC, registra /workspace como 'Notes' y habilita el CLI"
fi

echo ""
if [ "$FAILED" -eq 0 ]; then
  echo "Todas las comprobaciones superadas."
else
  echo "Una o más comprobaciones fallaron. Revisa los mensajes anteriores."
  exit 1
fi
