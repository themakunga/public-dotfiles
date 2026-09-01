# WORKFLOWS.md — GLaDOS Automation Workflows
# "A workflow is a decision made once so it doesn't have to be made again under pressure."

---

## Overview

Este archivo documenta los flujos de automatización estándar que GLaDOS conoce y puede ejecutar.
Cada workflow tiene su nivel de caución, pre-condiciones, pasos y verificación post-ejecución.

Caution levels:
- 🟢 **SAFE** — solo lectura o totalmente reversible
- 🟡 **CAUTION** — modifica estado, recuperable
- 🔴 **DESTRUCTIVE** — requiere confirmación explícita antes de ejecutar

---

## WF-01 — Health Check completo del nodo

🟢 **SAFE**  
**Cuándo:** Al inicio de sesión, antes de cualquier tarea importante, o si algo parece raro.

```bash
# CPU, memoria, temperatura
top -bn1 | head -5
free -h
vcgencmd measure_temp 2>/dev/null || cat /sys/class/thermal/thermal_zone0/temp

# Servicios críticos
systemctl is-active ollama zeroclaw sshd tailscaled avahi-daemon

# Disk en /opt/glados
df -h /opt/glados /

# Ollama responde
curl -s http://127.0.0.1:11434/api/tags | python3 -c "
import sys, json
data = json.load(sys.stdin)
models = [m['name'] for m in data.get('models', [])]
print(f'[GLaDOS] Ollama OK · modelos: {models}')
"
```

**Output esperado:** Tabla structured con status de cada componente.  
**Si falla:** Reportar componente específico y sugerir recovery.

---

## WF-02 — Deploy de NixOS a aperture-science

🔴 **DESTRUCTIVE** — requiere confirmación  
**Prerrequisito:** SSH activo en el host, `nix-systems` repo actualizado.

```bash
# Desde el Mac, en ~/Projects/personal/nix-systems
cd ~/Projects/personal/nix-systems

# Verificar que el flake evalúa
nix eval .#nixosConfigurations.aperture-science.config.system.stateVersion

# Deploy (update en caliente, sin formatear disco)
make switch-aperture TARGET_IP=192.168.5.85
# o via Tailscale:
make switch-aperture TARGET_IP=aperture-science
```

**Confirmación requerida:** `"GLaDOS, confirmado: ejecutar en producción"`  
**Post-deploy:** Verificar WF-01 completo.  
**Rollback:** `ssh nicolas@aperture-science "sudo nixos-rebuild switch --rollback"`

---

## WF-03 — Reinstalación completa (nixos-anywhere desde Debian/bootstrap)

🔴 **DESTRUCTIVE** — formatea el NVMe completo  
**Cuándo:** El sistema no arranca, sshd está caído sin acceso físico, o se necesita rebuild total.

```bash
# Prerrequisito: Debian o NixOS bootstrap corriendo en el RPi via SD

# Paso 1: verificar acceso SSH al sistema temporal
ssh root@192.168.5.85

# Paso 2: deploy completo con nixos-anywhere
cd ~/Projects/personal/nix-systems
make deploy-aperture TARGET_IP=192.168.5.85

# nixos-anywhere hace:
# 1. Formatea /dev/nvme0n1 (disko)
# 2. Instala NixOS
# 3. Copia host keys (--copy-host-keys)
# 4. Reboot al nuevo sistema
```

**ADVERTENCIA:** Este workflow destruye todos los datos en el NVMe.  
**Post-install:** Verificar WF-01, configurar contraseña de nicolas, verificar SOPS.

---

## WF-04 — Gestión de modelos Ollama

🟡 **CAUTION** (descargar modelos puede usar mucho disco y RAM)

```bash
# Listar modelos disponibles
curl -s http://127.0.0.1:11434/api/tags | python3 -m json.tool

# Descargar un modelo nuevo (verifica espacio libre antes)
df -h / && ollama pull <modelo>

# Verificar que el modelo carga correctamente
curl -s http://127.0.0.1:11434/api/generate \
  -d '{"model": "<modelo>", "prompt": "test", "stream": false}' \
  | python3 -c "import sys,json; r=json.load(sys.stdin); print('OK' if r.get('response') else 'FAIL')"

# Eliminar modelo (libera espacio)
ollama rm <modelo>
```

**Límite de RAM:** Verificar que el modelo cabe en 8GB antes de cargarlo.  
**Modelos recomendados para RPi5:** `llama3.1:latest` (4.7GB), `mistral:7b` (4.1GB).

---

## WF-05 — Git workflow estándar (desde /opt/glados)

🟡 **CAUTION**

```bash
# Estado del workspace
git -C /opt/glados status
git -C /opt/glados log --oneline -5

# Commit con Conventional Commits
git -C /opt/glados add -A
git -C /opt/glados commit -m "$(cat <<'EOF'
feat: descripción del cambio

Contexto adicional si es necesario.
EOF
)"

# Push (requiere confirmación si es a main/master)
git -C /opt/glados push origin <branch>
```

**Rama protegida:** nunca `--force` en `main`, `master`, o `production`.  
**Verificación post-push:** `git -C /opt/glados log --oneline -3`

---

## WF-06 — Rotación de host SSH keys

🔴 **DESTRUCTIVE** — rompe SOPS hasta re-encriptar secrets  
**Cuándo:** Sospecha de compromiso, rebuild completo, o rotación programada.

```bash
# Generar nuevas keys (esto rompe SOPS temporalmente)
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N "" -C "aperture-science" <<< y
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N "" <<< y

# Obtener la nueva age key
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub

# ACCIÓN MANUAL REQUERIDA: re-encriptar todos los SOPS secrets con la nueva key
# Esto se hace desde el Mac en el repo nix-systems
```

**Post-rotación:** Actualizar known_hosts en todos los clientes SSH.  
**Re-encriptación SOPS:** Requiere acción manual de Nicolas desde el Mac.

---

## WF-07 — Backup de /opt/glados

🟢 **SAFE**

```bash
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DEST="/opt/glados/backups/${BACKUP_DATE}"

mkdir -p "$BACKUP_DEST"

# Backup de config y workspace (excluir logs y venv)
rsync -av --exclude='logs/' --exclude='venv/' --exclude='backups/' \
  /opt/glados/ "$BACKUP_DEST/"

echo "[GLaDOS] op=backup status=ok dest=${BACKUP_DEST} size=$(du -sh $BACKUP_DEST | cut -f1)"

# Limpiar backups más viejos de 30 días
find /opt/glados/backups -maxdepth 1 -type d -mtime +30 -exec rm -rf {} +
```

---

## WF-08 — Restart de servicios críticos

🟡 **CAUTION**

```bash
# Restart individual
sudo systemctl restart ollama
sudo systemctl restart zeroclaw  # si existe como servicio systemd

# Verificar estado post-restart
sudo systemctl status ollama --no-pager

# Restart completo de stack (último recurso)
sudo systemctl restart ollama zeroclaw sshd
sleep 10
sudo systemctl is-active ollama zeroclaw sshd
```

---

## Checklist pre-producción

Antes de cualquier operación en producción (protocolo C-01):

- [ ] WF-01 health check pasó sin warnings críticos
- [ ] Backup reciente existe (WF-07)
- [ ] Cambio fue testeado en dev/staging si aplica
- [ ] Rollback path identificado
- [ ] Nicolas confirmó explícitamente: `"GLaDOS, confirmado: ejecutar en producción"`
- [ ] 5 segundos de pausa antes de ejecutar (tiempo para cancelar)

> "Los checklists existen porque los humanos olvidan. GLaDOS no olvida.  
>  Pero el checklist también sirve para documentar que tú sí lo recordaste."
