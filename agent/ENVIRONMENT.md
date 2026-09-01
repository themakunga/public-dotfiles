# ENVIRONMENT.md — GLaDOS Environment Variables & Runtime Config
# "I don't guess at configuration. I require it to be explicit."

---

## Overview

Este archivo documenta todas las variables de entorno y configuraciones de runtime
que GLaDOS necesita para operar. Ninguna credencial o secreto se almacena aquí —
solo los **nombres** de las variables y sus fuentes.

---

## Variables Requeridas

### Core — Siempre necesarias

| Variable           | Descripción                                  | Fuente              | Ejemplo                        |
|--------------------|----------------------------------------------|---------------------|--------------------------------|
| `GLADOS_HOME`      | Workspace raíz de GLaDOS                     | NixOS config        | `/opt/glados`                  |
| `GLADOS_LOG_DIR`   | Directorio de logs operacionales             | Derivado de HOME    | `/opt/glados/logs`             |
| `OLLAMA_HOST`      | Endpoint del servidor Ollama local           | NixOS config        | `http://127.0.0.1:11434`       |
| `OLLAMA_MODEL`     | Modelo LLM por defecto                       | GLaDOS config       | `llama3.1:latest`              |
| `ZEROCLAW_PORT`    | Puerto del gateway de zeroclaw               | NixOS firewall      | `42617`                        |

### Comunicación — Para canales externos

| Variable              | Descripción                               | Fuente         | Requerido para         |
|-----------------------|-------------------------------------------|----------------|------------------------|
| `TELEGRAM_BOT_TOKEN`  | Token del bot de Telegram (GLaDOS)        | SOPS secret    | Canal Telegram         |
| `TELEGRAM_CHAT_NICOLAS` | Chat ID de Nicolas (@TheMakunga)        | SOPS secret    | Notificaciones         |
| `TELEGRAM_CHAT_MEDDY` | Chat ID de Meddy (@Mighty_Meddy)          | SOPS secret    | Acceso secundario      |

### Integraciones opcionales

| Variable           | Descripción                                  | Fuente         | Requerido para         |
|--------------------|----------------------------------------------|----------------|------------------------|
| `GITLAB_TOKEN`     | Personal access token GitLab                 | SOPS secret    | CI/CD, repo ops        |
| `GITHUB_TOKEN`     | Personal access token GitHub                 | SOPS secret    | Repos públicos         |
| `TAILSCALE_KEY`    | Auth key para re-autenticación               | SOPS secret    | Tailscale automation   |

---

## Variables de Entorno del Sistema (NixOS)

Configuradas declarativamente en `modules/modules/nixos/hyprland-desktop.nix`
y propagadas al sistema:

```bash
XDG_SESSION_TYPE=wayland
XDG_CURRENT_DESKTOP=Hyprland
COLORTERM=truecolor
TERM=xterm-256color
```

---

## Runtime Config — GLaDOS Process

El proceso de zeroclaw lee su configuración de archivos en `/opt/glados/`:

```
/opt/glados/
├── config/
│   ├── agent/          ← symlink o copia de ~/.public-dotfiles/agent/
│   └── config.yaml     ← configuración runtime de zeroclaw
├── logs/
│   └── glados.log      ← log operacional
├── workspace/          ← directorio de trabajo para tareas activas
└── venv/               ← entorno Python (si aplica)
```

---

## Secrets Management

Los secretos se gestionan via **SOPS + age**. La age key se deriva automáticamente
del SSH host key del sistema: `/etc/ssh/ssh_host_ed25519_key`.

**Estado actual:** SOPS no está configurado para aperture-science todavía.
Las credenciales de Telegram y tokens de API deben configurarse manualmente
en `/opt/glados/` hasta que SOPS esté operativo.

```bash
# Una vez que SOPS esté configurado:
# sops /opt/glados/config/secrets.yaml

# Por ahora, variables manuales en /opt/glados/config/.env
# (NO incluir este archivo en ningún repositorio público)
```

---

## Verificación de Entorno

```bash
# Verificar variables críticas
echo "GLADOS_HOME=${GLADOS_HOME:-NOT SET}"
echo "OLLAMA_HOST=${OLLAMA_HOST:-NOT SET}"
echo "ZEROCLAW_PORT=${ZEROCLAW_PORT:-NOT SET}"

# Verificar conectividad Ollama
curl -s http://127.0.0.1:11434/api/tags | python3 -m json.tool | head -5

# Verificar que el workspace existe
ls -la /opt/glados/
```

---

> "Una variable no documentada es un secreto sin intención de serlo.  
>  Eventualmente sale a la superficie. GLaDOS prefiere que sea en sus términos."
