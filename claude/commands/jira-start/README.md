# jira-start

Skill agnóstica (Claude Code / Codex / terminal) para iniciar desarrollo desde un ticket Jira.

**Qué hace:**

- Detecta si el repo es GitHub o GitLab (cloud o self-hosted)
- Obtiene título, prioridad, fecha límite y tareas del ticket
- Crea la branch `feature/PROJ-123-titulo-del-ticket`
- Asigna el ticket al usuario autenticado en Jira
- Detecta tecnologías del repo (go, node, docker, nix…)
- Crea o actualiza `todo.txt` en formato estándar [todotxt.org](https://todotxt.org)

---

## Prereqs

| Herramienta                    | Requerida | Notas                                           |
| ------------------------------ | --------- | ----------------------------------------------- |
| `jira` (ankitpokhrel/jira-cli) | ✅        | Acceso a Jira + autenticación                   |
| `git`                          | ✅        | Ya instalado en cualquier sistema               |
| `jq`                           | Opcional  | Mejor parsing de descripción si está disponible |

---

## Instalar jira-cli

### Homebrew (macOS / Linux)

```bash
brew install ankitpokhrel/tap/jira-cli
```

### curl — descarga directa (Linux / macOS sin Homebrew)

```bash
ARCH=$(uname -m | sed 's/x86_64/x86_64/; s/aarch64/arm64/; s/arm64/arm64/')
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
curl -s https://api.github.com/repos/ankitpokhrel/jira-cli/releases/latest \
  | grep "browser_download_url.*${OS}_${ARCH}.tar.gz" \
  | cut -d'"' -f4 \
  | xargs curl -sL \
  | tar xz -C /tmp jira
mkdir -p ~/.local/bin
mv /tmp/jira ~/.local/bin/jira
chmod +x ~/.local/bin/jira
```

### Nix — NixOS (`nix-systems` flake)

Añadir en `modules/profiles/terminal-tools.nix` (o el host específico):

```nix
environment.systemPackages = with pkgs; [
  jira-cli   # ankitpokhrel/jira-cli — workflow CLI
];
```

Si la versión en stable es muy antigua: usar `pkgs.unstable.jira-cli`.

### Nix — nix-darwin (macOS)

Mismo patrón en el módulo darwin correspondiente.

---

## Configuración inicial

```bash
jira init
# Pedirá:
#   - URL de tu Jira:  https://miempresa.atlassian.net
#   - Email:           tu@email.com
#   - API token:       generar en https://id.atlassian.com/manage-profile/security/api-tokens
```

### GitLab self-hosted (opcional)

Si usas un GitLab corporativo en dominio propio, registra el hostname:

```bash
mkdir -p ~/.config/claude-skills
echo "gitlab.miempresa.com" >> ~/.config/claude-skills/gitlab-hosts
# Un hostname por línea — sin protocolo, sin path
```

---

## Agregar los stow packages a dotfiles

En el host NixOS (`aperture-science.nix`) o darwin, añadir al array de paquetes del usuario:

```nix
# Paquete claude — ~/.claude/ (skills y comandos Claude Code)
{ name = "claude"; }

# Paquete scripts — ~/scripts/ (scripts ejecutables como jira-start)
# Asegurarse de que ~/scripts está en PATH (ver .bashrc)
```

Agregar `~/scripts` al PATH si no está ya:

```bash
# En bash/.bashrc:
export PATH="$HOME/scripts:$PATH"
```

---

## Uso

### Desde Claude Code

```
/jira-start PROJ-123
```

### Desde Codex / ZeroClaw

```
jira-start PROJ-123
```

### Desde terminal

```bash
~/scripts/jira-start PROJ-123
# O si ~/scripts está en PATH:
jira-start PROJ-123
```

---

## Formato de todo.txt generado

```
(B) 2026-09-25 Implementar autenticación de usuarios PROJ-123 due:2026-10-15 +go +docker
(B) 2026-09-25 Escribir tests de integración PROJ-123 due:2026-10-15 +go +docker
```

Mapeo de prioridad Jira → todo.txt: `Highest→A | High→B | Medium→C | Low→D | Lowest→E`
