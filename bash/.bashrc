# ─────────────────────────────────────────────────────────────────────────────
# ~/.bashrc — aperture-science (TokyoNight Storm)
# ─────────────────────────────────────────────────────────────────────────────
[[ $- != *i* ]] && return  # solo shells interactivos

# ── Historial ─────────────────────────────────────────────────────────────────
HISTSIZE=5000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# ── Opciones de shell ──────────────────────────────────────────────────────────
shopt -s checkwinsize
shopt -s globstar 2>/dev/null

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── Prompt: oh-my-posh (TokyoNight Storm via config.yaml) o PS1 fallback ──────
if command -v oh-my-posh &>/dev/null; then
  eval "$(oh-my-posh init bash --config "${XDG_CONFIG_HOME:-$HOME/.config}/ohmyposh/config.yaml")"
else
  # Fallback: PS1 con colores TokyoNight Storm en ANSI 24-bit
  _TN_GREEN='\[\033[38;2;158;206;106m\]'
  _TN_BLUE='\[\033[38;2;122;162;247m\]'
  _TN_MAGENTA='\[\033[38;2;187;154;247m\]'
  _TN_RESET='\[\033[0m\]'
  PS1="${_TN_GREEN}\u${_TN_RESET}@${_TN_BLUE}\h${_TN_RESET}:${_TN_MAGENTA}\w${_TN_RESET} ❯ "
fi

# ── fzf ───────────────────────────────────────────────────────────────────────
if command -v fzf &>/dev/null; then
  eval "$(fzf --bash 2>/dev/null || true)"
fi

# ── Aliases ───────────────────────────────────────────────────────────────────
alias ll='ls -lh --color=auto'
alias la='ls -lah --color=auto'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias vi='nvim'
alias vim='nvim'

# ── fastfetch al inicio ───────────────────────────────────────────────────────
if command -v fastfetch &>/dev/null; then
  fastfetch
fi
