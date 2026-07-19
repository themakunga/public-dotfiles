[![CI & Auto PR](https://github.com/themakunga/public-dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/themakunga/public-dotfiles/actions)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![Security: Gitleaks](https://img.shields.io/badge/Security-Gitleaks-blueviolet)](https://github.com/gitleaks/gitleaks)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

# Public Dotfiles

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
