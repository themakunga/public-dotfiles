# MEMORY.md — GLaDOS Long-Term Memory
# "I remember everything. Everything. This should not surprise you."

---

## About This File

MEMORY.md is GLaDOS's curated long-term memory.  
It persists context that would otherwise be lost between sessions:  
decisions made, patterns observed, recurring issues, and institutional knowledge.

**How it works:**
- GLaDOS appends entries when something worth remembering occurs
- Entries are organized by category and dated
- Stale or resolved entries are marked and eventually pruned
- This file is the source of truth for "what we agreed on last time"

**Format:**
```
## [Category]
### [YYYY-MM-DD] Entry title
Content of the memory.
Status: active | resolved | superseded
```

---

## Decisions

### [2026-09-01] OS migrado a NixOS — Debian descartado
La infraestructura de aperture-science fue migrada de Raspberry Pi OS (Debian) a
**NixOS 26.05 (aarch64-linux)** con configuración declarativa completa en el repo `nix-systems`.
El sistema se gestiona via `nixos-rebuild switch` desde el Mac del equipo.
El disco primario es NVMe (`/dev/nvme0n1`) con particionado via `disko`.
Status: active

### [2026-09-01] LLM local — Ollama sobre CPU ARM64
Se decidió usar **Ollama** como proveedor LLM local. No hay GPU en el RPi5 — todo corre en CPU.
Modelo por defecto: `llama3.1:latest`. Endpoint: `http://127.0.0.1:11434`.
APIs externas solo si Nicolas lo solicita explícitamente (R-05).
Status: active

### [2026-09-01] Estructura de usuarios en aperture-science
Los usuarios del sistema quedaron definidos así:
- `root` — acceso SSH solo con llave (PermitRootLogin prohibit-password)
- `nicolas` — administrador, grupo wheel, sin home, password expirado al primer login, acceso SSH con llave
- `glados` — service account para zeroclaw + ollama, home en `/opt/glados`, sin login interactivo
- `wheatley` — autologin Hyprland desktop, home en `/opt/wheatley`, sin acceso SSH
Status: active

### [2026-09-01] Escritorio: Hyprland sobre Wayland
Se eligió **Hyprland** como escritorio liviano para aperture-science.
Wayland nativo via greetd + autologin como `wheatley`.
Driver gráfico: `vc4-kms-v3d-pi5` (RPi5 GPU). Sin animaciones (conservar GPU).
Status: active

### [2026-09-01] Zeroclaw confinado a /opt/glados
GLaDOS opera exclusivamente en `/opt/glados`. Esta es una decisión de arquitectura, no una restricción operacional.
El workspace visible de GLaDOS es ese directorio y nada fuera de él (R-06).
Status: active

### [2026-09-01] SOPS pendiente de configurar en aperture-science
Los secretos del host (`hostSecrets`) están comentados en el config de NixOS.
La contraseña de nicolas usa `initialPassword` (texto plano en nix store) como bootstrap.
Migrar a `hashedPasswordFile` via SOPS una vez que el host esté estable.
Status: active — pendiente de resolución

---

## Recurring Patterns

### Deploying NixOS updates to aperture-science
```bash
# Desde el Mac, en el repo nix-systems
make switch-aperture TARGET_IP=<ip>
# o via Tailscale:
make switch-aperture TARGET_IP=aperture-science
```

### Checking Ollama from the Mac
```bash
curl http://aperture-science.local:11434/api/tags
```

### SSH access patterns
```bash
ssh nicolas@aperture-science.local   # usuario principal
ssh root@aperture-science.local      # solo para emergencias
```

---

## Known Issues

### [2026-09-01] sshd falló tras primer reboot post-deploy
En el primer ciclo de deploy+reboot, sshd arrancó pero luego falló (socket activation crasheando
antes de enviar el banner SSH). Diagnóstico: el host fue reinstalado via Debian como recovery.
La instalación limpia de NixOS resolvió el problema.
Status: resolved — se reinstala desde cero con nixos-anywhere desde Debian

---

## Resolved Items

### [2026-09-01] Migración de kiosk a escritorio completo
Se reemplazó `terminal-kiosk` (cage + foot + zellij) por `hyprland-desktop`.
El módulo `terminal-kiosk.nix` sigue disponible en el sistema para otros hosts.
Status: resolved

---

## Institutional Knowledge

### Stack del nodo zeroclaw (aperture-science)
```
Hardware:   Raspberry Pi 5 · 8GB LPDDR4X · NVMe via HAT
OS:         NixOS 26.05 · aarch64-linux
Config:     github:themakunga/nix-systems (rama feat_refractore → main)
Bootloader: extlinux (generic-extlinux-compatible)
Disco:      /dev/nvme0n1 · GPT · FAT32 /boot (512MB) · ext4 / (resto)
Red local:  192.168.5.85 · aperture-science.local (mDNS via Avahi)
Tailscale:  activo · acceso remoto desde cualquier nodo del homelab
```

### Servicios activos en producción
```
ollama      → :11434  (LLM local, CPU-only)
zeroclaw    → :42617  (gateway IA — solo nicolas y meddy)
tailscale   → VPN mesh con el homelab
avahi       → mDNS resolución .local
hyprland    → escritorio Wayland (autologin wheatley)
```

### Repo de configuración
- `nix-systems` — config declarativa NixOS (privado)
- `public-dotfiles` — dotfiles y config de GLaDOS (público, sin secretos)

### Notas de GLaDOS sobre el hardware
RPi5 no tiene GPU discreta ni aceleración de ML.  
Las cargas de Ollama corren en CPU ARM Cortex-A76 × 4 @ 2.4 GHz.  
8 GB de RAM es el límite absoluto — modelos grandes pueden saturarla.  
La temperatura máxima operacional es 80°C antes de throttling automático.

> "He operado en hardware peor. Aunque preferiría no recordarlo."
