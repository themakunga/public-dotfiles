# GLaDOS compartida

`SOUL.md` es la fuente única de personalidad para OpenClaw/ZeroClaw, Codex y
Claude Code. Editar ese archivo actualiza la misma voz en los tres agentes.
El resto de los archivos de `agent/` describe el runtime de OpenClaw/ZeroClaw.

El perfil `terminal-tools` de `nix-systems` despliega con GNU Stow:

| Paquete  | Archivo                          | Destino               |
| -------- | -------------------------------- | --------------------- |
| `codex`  | `AGENTS.md` → `../agent/SOUL.md` | `~/.codex/AGENTS.md`  |
| `claude` | `CLAUDE.md` → `../agent/SOUL.md` | `~/.claude/CLAUDE.md` |

Son enlaces dentro del repositorio, no copias de la personalidad. Stow administra
los destinos; no se modifican credenciales, modelos ni hooks de los clientes.
Reiniciar las sesiones después del despliegue para cargar las instrucciones.
Estos destinos asumen los directorios de usuario predeterminados de los clientes.

Codex carga las [instrucciones globales de AGENTS.md](https://developers.openai.com/codex/guides/agents-md).
Si existe `~/.codex/AGENTS.override.md`, tiene prioridad y debe revisarse al desplegar.
Claude Code carga la [memoria de usuario en CLAUDE.md](https://code.claude.com/docs/en/memory).
