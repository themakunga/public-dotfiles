[![CI & Auto PR](https://github.com/themakunga/public-dotfiles/actions/workflows/ci.yaml/badge.svg)](https://github.com/themakunga/public-dotfiles/actions/workflows/ci.yaml)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![Security: Gitleaks](https://img.shields.io/badge/Security-Gitleaks-blueviolet)](https://github.com/gitleaks/gitleaks)

# Public Dotfiles

![Lua](https://img.shields.io/badge/Lua-2C2D72?style=flat-square&logo=lua&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-4EAA25?style=flat-square&logo=gnubash&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-57A143?style=flat-square&logo=neovim&logoColor=white)

Repositorio centralizado para el almacenamiento, versionado y despliegue de archivos de configuración del sistema (dotfiles).

## Dependencias y Requisitos Previos

Para utilizar y desarrollar en este repositorio, asegúrate de tener instaladas las siguientes herramientas en tu entorno local:

- Git: Para el control de versiones.
- Pre-commit: Para la ejecución de hooks locales antes de cada commit.
- Gitleaks: Herramienta de análisis estático para prevenir la filtración de secretos (ejecutada mediante pre-commit y CI).
- Node.js & npm (Opcional pero recomendado): Para herramientas de validación de commits locales si decides integrar Commitizen o Husky.

## Instalación y Uso

1. Clona el repositorio en tu máquina local:
   git clone https://github.com/themakunga/public-dotfiles.git ~/.dotfiles
   cd ~/.dotfiles

2. (Aquí puedes agregar el comando específico que usas para enlazar tus dotfiles, por ejemplo, usando GNU Stow o un script bash personalizado).
   # Ejemplo usando un script de instalación
   ./install.sh

## Flujo de Desarrollo

Este repositorio sigue un flujo de trabajo estructurado e integrado con GitHub Actions para garantizar la calidad y seguridad del código.

### 1. Gestión de Ramas

- main: Rama de producción. No se deben hacer commits directos aquí.
- develop: Rama principal de desarrollo. Todos los cambios deben integrarse primero en esta rama.

Cuando se realiza un push a la rama develop, el pipeline de Integración Continua (CI) ejecuta las validaciones y, si son exitosas, genera automáticamente un Pull Request hacia main.

### 2. Configuración del Entorno de Desarrollo

Para evitar que el pipeline falle remotamente, debes configurar la validación de secretos de forma local:

# 1. Instalar pre-commit (si usas Python/pip)

pip install pre-commit

# 2. Instalar los hooks en el repositorio

pre-commit install

Esto garantizará que Gitleaks analice tu código localmente antes de permitir la creación de un commit.

### 3. Convención de Commits

Este proyecto utiliza Commitlint. Todos los mensajes de commit deben seguir la especificación de Conventional Commits (https://www.conventionalcommits.org/).

Formato requerido:
<tipo>[ámbito opcional]: <descripción>

Tipos permitidos:

- feat: Nueva característica o archivo de configuración.
- fix: Solución de errores.
- chore: Mantenimiento, actualización de dependencias o ajustes de CI.
- docs: Cambios en la documentación.
- style: Formato de código (espacios, comas, etc).
- refactor: Refactorización de código sin agregar funcionalidades ni corregir errores.

Ejemplo válido:
git commit -m "feat(zsh): agregar alias para actualización del sistema"

### 4. Reglas de Validación en CI

El pipeline de GitHub Actions validará los siguientes puntos en cada push a develop:

1.  Commitlint: Verifica que el historial de commits respete la nomenclatura estándar.
2.  Gitleaks: Escanea el código en busca de credenciales, tokens o llaves privadas expuestas.
3.  Archivos del Sistema: Bloquea la subida de archivos residuales como .DS_Store, Thumbs.db, .env, .pem o .key.

## Licencia

Este proyecto está distribuido bajo la licencia MIT. Consulta el archivo LICENSE para más información.

## Repository reference

| Path                   | Purpose                             |
| ---------------------- | ----------------------------------- |
| [`nvim/`](nvim/)       | Neovim configuration                |
| [`tmux/`](tmux/)       | tmux configuration                  |
| [`handy/`](handy/)     | Handy dictation configuration       |
| [`zsh/`](zsh/)         | Zsh configuration                   |
| [`scripts/`](scripts/) | Maintenance and validation commands |

The default branch is `main`. Use the tracked manifests and scripts above
when preparing changes; keep local credentials and generated files out of commits.

## CSpell project scope

Neovim checks all file types only when the project root contains its own CSpell
configuration file, or a `cspell` object in the root `package.json`. Configurations
only inside `.config/`, `.vscode/` or other subdirectories do not opt the project
in. Nested Git repositories opt in independently.

Use the root configuration's `files` and `ignorePaths` to select files. For example,
save `.cspell.config.yaml` at the project root:

```yaml
version: "0.2"
files:
  - "**/*"
ignorePaths:
  - "dist/**"
  - "generated/**"
```

The override in `nvim/after/lsp/cspell_ls.lua` uses the official
`cspell-language-server` supplied by the Nix Neovim module; the old Mason
`cspell-lsp` is not a compatible substitute. Executable configuration files use
Neovim's native trust approval. From `nvim/`, run:

```sh
nvim --headless -u NONE -i NONE -l tests/project-lsp.lua
nvim --headless -u NONE -i NONE -l tests/cspell-scope.lua
```

The scope check requires `nvim-lspconfig` and the official server on `PATH`. It
verifies root opt-in, normal/custom/unset file types and real file exclusions.
