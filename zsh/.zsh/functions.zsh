# ===== AUTOMATIZACIÓN NVM (.nvmrc) =====
autoload -U add-zsh-hook

load-nvmrc() {
  # Validar que nvm esté cargado antes de ejecutar
  command -v nvm &>/dev/null || return

  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [[ -n "$nvmrc_path" ]]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [[ "$nvmrc_node_version" = "N/A" ]]; then
      nvm install
    elif [[ "$nvmrc_node_version" != "$node_version" ]]; then
      nvm use
    fi
  elif [[ "$node_version" != "$(nvm version default)" ]]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc

# ===== SELECCIÓN DINÁMICA DE CONFIG NEOVIM =====
vv() {
  # Asegura que fd y fzf existan
  if ! command -v fd &>/dev/null || ! command -v fzf &>/dev/null; then
    nvim "$@"
    return
  fi

  local config
  config=$(fd --max-depth 1 --glob 'nvim-*' "${HOME}/.config" | fzf --prompt="Neovim Configs > " --height=~50% --layout=reverse --border --exit-0)

  if [[ -z "$config" ]]; then
    echo "No config selected"
    return
  fi

  NVIM_APPNAME="$(basename "$config")" nvim "$@"
}

# ===== AI → MARKDOWN (glow) =====

# claude-md <prompt>  — ejecuta claude -p y renderiza con glow
claude-md() {
  if [[ $# -eq 0 ]]; then
    echo "Uso: claude-md <prompt>"
    return 1
  fi
  claude -p "$*" | glow -
}

# codex-md <prompt>  — ejecuta codex en modo no interactivo y renderiza con glow
# (descomenta el flag correcto cuando codex esté instalado)
codex-md() {
  if [[ $# -eq 0 ]]; then
    echo "Uso: codex-md <prompt>"
    return 1
  fi
  # codex exec "$*" | glow -   # ajustá el subcomando si codex lo requiere
  codex "$*" | glow -
}

# mdv [archivo|texto]  — renderiza un archivo .md o texto plano con glow
# (no usar 'md' porque es alias de 'mkdir -p')
mdv() {
  if [[ -p /dev/stdin ]]; then
    # Hay pipe entrante: renderizar stdin
    glow -
  elif [[ -f "$1" ]]; then
    glow "$1"
  elif [[ $# -gt 0 ]]; then
    echo "$*" | glow -
  else
    echo "Uso: mdv <archivo.md>  |  comando | mdv  |  mdv \"texto markdown\""
    return 1
  fi
}

# ===== INTEGRACIÓN DE TMUX INTELIGENTE (SSH) =====
if [[ -z "$TMUX" && -n "$SSH_TTY" ]] && command -v tmux &>/dev/null; then
  local session_ids
  session_ids="$(tmux list-sessions 2>/dev/null)"

  if [[ -z "$session_ids" ]]; then
    tmux new-session
  else
    local create_new="Create new session"
    local start_without="Start without tmux"
    local choice

    # Genera el menú fzf de manera eficiente
    choice=$(printf "%s\n%s\n%s" "$session_ids" "$create_new" "$start_without" | fzf --height=40% --reverse | cut -d: -f1)

    # Evalúa la selección usando expresiones nativas de Zsh en vez de 'expr'
    if [[ "$choice" =~ '^[0-9]+$' ]]; then
      tmux attach-session -t "$choice"
    elif [[ "$choice" == "$create_new" ]]; then
      tmux new-session
    fi
  fi
fi
