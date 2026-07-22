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
