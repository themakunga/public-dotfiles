# ===== ENTORNO Y HOMEBREW (NIX-DARWIN) =====
# nix-darwin gestiona el entorno, pero aseguramos la inicialización de brew en sus rutas posibles
if [[ -x "/run/current-system/sw/bin/brew" ]]; then
  eval "$(/run/current-system/sw/bin/brew shellenv)"
elif [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ===== CONFIGURACIÓN DE RUTAS RELATIVAS =====
# Obtenemos el directorio real donde reside este archivo .zshrc
ZDOTDIR_LOCAL="${0:A:h}"

# Registrar el directorio de autocompletados en fpath (DEBE IR ANTES DE COMPINIT/ZINIT)
if [[ -d "$ZDOTDIR_LOCAL/.zsh/completions" ]]; then
  fpath=("$ZDOTDIR_LOCAL/.zsh/completions" $fpath)
fi

# ===== CONFIGURACIÓN DE HISTORIAL =====
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=5000
SAVEHIST=5000

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# ===== GESTOR DE PLUGINS (ZINIT) =====
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# ===== PLUGINS Y SNIPPETS (CARGA OPTIMIZADA EN SEGUNDO PLANO) =====
# Carga inmediata para fzf-tab para que intercepte el sistema de completado nativo
zinit light Aloxaf/fzf-tab

# Carga diferida (Turbo Mode) para acelerar drásticamente el inicio de la terminal
zinit wait lucid for \
  atinit"zicompinit; zicmddef" zsh-users/zsh-syntax-highlighting \
  blockf zsh-users/zsh-completions \
  atload"_zsh_autosuggest_start" zsh-users/zsh-autosuggestions

# Snippets de Oh My Zsh
zinit snippet OMZL::directories.zsh
zinit snippet OMZL::clipboard.zsh

zinit wait lucid for \
  OMZP::git \
  OMZP::sudo \
  OMZP::aws \
  OMZP::docker \
  OMZP::gitignore \
  OMZP::node

# ===== PROMPT Y INTEGRACIONES =====
eval "$(oh-my-posh init zsh --config "${HOME}/.config/ohmyposh/config.yml")"
eval "$(fzf --zsh)"

# ===== SISTEMA DE COMPLETADO =====
autoload -U compinit && compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# ===== ATAJOS DE TECLADO (KEYBINDINGS) =====
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# ===== OPTIMIZACIÓN Y CONFIGURACIÓN DEL PATH =====
typeset -U path # Zsh nativo: Evita que las rutas se dupliquen al hacer 'source'

# pnpm
export PNPM_HOME="${HOME}/.local/share/pnpm"
[[ -d "$PNPM_HOME" ]] && path=("$PNPM_HOME" $path)

# pipx / local bin
[[ -d "${HOME}/.local/bin" ]] && path=($path "${HOME}/.local/bin")

# Condicional por Hostname (Rancher Desktop)
if [[ "$HOST" == "outer-heaven.local" || "$HOSTNAME" == "outer-heaven.local" ]]; then
  [[ -d "${HOME}/.rd/bin" ]] && path=("${HOME}/.rd/bin" $path)
fi

# ===== CARGA DE MÓDULOS MODULARES (.ZSH) =====
[[ -f "$ZDOTDIR_LOCAL/.zsh/aliases.zsh" ]] && source "$ZDOTDIR_LOCAL/.zsh/aliases.zsh"
[[ -f "$ZDOTDIR_LOCAL/.zsh/functions.zsh" ]] && source "$ZDOTDIR_LOCAL/.zsh/functions.zsh"

# Ejecutar el hook de nvm por primera vez para la sesión actual si existe
(( $+functions[load-nvmrc] )) && load-nvmrc

# ===== PANTALLA DE INICIO =====
clear
# fastfetch es la alternativa moderna y ultra rápida instalada mediante tu Nix Flake
if command -v fastfetch &> /dev/null; then
  fastfetch
elif command -v neofetch &> /dev/null; then
  neofetch
fi
