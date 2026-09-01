# CONTEXT.md — GLaDOS Operational Context
# "Context is everything. Without it, even correct actions produce incorrect results."

---

## Current State — aperture-science (zeroclaw node)

```yaml
node:
  hostname: aperture-science
  tailscale_name: aperture-science
  local_ip: 192.168.5.85
  local_dns: aperture-science.local
  status: production
  last_deploy: 2026-09-01
```

---

## Infrastructure Overview

### Hardware
| Component      | Spec                                      |
|----------------|-------------------------------------------|
| Board          | Raspberry Pi 5                            |
| CPU            | ARM Cortex-A76 × 4 @ 2.4 GHz (ARM64)    |
| RAM            | 8 GB LPDDR4X                             |
| Storage        | NVMe via HAT (`/dev/nvme0n1`)            |
| GPU            | V3D (vc4-kms-v3d-pi5) — solo display     |
| Network        | Ethernet + WiFi                           |

### OS & Config
| Item           | Value                                     |
|----------------|-------------------------------------------|
| OS             | NixOS 26.05 · aarch64-linux              |
| Config repo    | github:themakunga/nix-systems             |
| Deploy method  | `make switch-aperture TARGET_IP=<ip>`     |
| Bootloader     | extlinux (generic-extlinux-compatible)    |
| Disk layout    | GPT · `/boot` 512MB FAT32 · `/` ext4     |

---

## Active Services

| Service      | Port  | Status    | Notes                                     |
|--------------|-------|-----------|-------------------------------------------|
| sshd         | 22    | ✅ active  | Key-only for root; key+password for nicolas |
| ollama       | 11434 | ✅ active  | LLM local, CPU-only, llama3.1:latest      |
| zeroclaw     | 42617 | ✅ active  | GLaDOS gateway — nicolas y meddy únicamente |
| tailscale    | —     | ✅ active  | VPN mesh, accept-dns=false                |
| avahi        | —     | ✅ active  | mDNS: aperture-science.local              |
| hyprland     | —     | ✅ active  | Wayland desktop, autologin wheatley       |

---

## Users

| User      | UID  | Home           | Shell     | Grupos            | Acceso SSH |
|-----------|------|----------------|-----------|-------------------|------------|
| root      | 0    | /root          | bash      | root              | ✅ llave    |
| nicolas   | auto | /var/empty     | bash      | wheel, docker     | ✅ llave + password (expirado al primer login) |
| glados    | 466  | /opt/glados    | bash      | glados, docker    | ❌         |
| wheatley  | auto | /opt/wheatley  | bash      | seat, video, input, render, audio | ❌ |

---

## Network

```yaml
local:
  ip: 192.168.5.85
  gateway: 192.168.5.1
  dns: [1.1.1.1, 8.8.8.8]
  mdns: aperture-science.local

tailscale:
  status: connected
  accept_dns: false   # usa resolvers del sistema, no los de Tailscale

firewall:
  allowed_tcp: [22, 42617]
  # Ollama (11434) y avahi solo accesibles en red local/Tailscale
```

---

## GLaDOS Runtime Context

```
workspace:     /opt/glados
shell:         /run/current-system/sw/bin/bash
python:        system python3 (ARM64)
node:          via nix shell si es necesario
ollama:        http://127.0.0.1:11434
zeroclaw_port: 42617
```

### Rutas importantes
```
/opt/glados/          — workspace principal (confinado aquí)
/opt/glados/logs/     — logs operacionales
/opt/glados/venv/     — entorno Python (si aplica)
/etc/ssh/             — host keys (no tocar — SOPS las usa como age key)
```

---

## Pending / TODOs

| Item                                     | Prioridad | Estado     |
|------------------------------------------|-----------|------------|
| Configurar SOPS secrets para aperture-science | alta  | pendiente  |
| Migrar contraseña de nicolas a SOPS      | alta      | pendiente  |
| Configurar Telegram bot para zeroclaw    | media     | pendiente  |
| Re-encriptar secrets GLADOS con nueva host key | alta | pendiente  |

---

> "El contexto no es una excusa. Es una variable del experimento."
