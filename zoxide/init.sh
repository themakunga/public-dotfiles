# Loaded by Nix in interactive Bash and Zsh sessions.
if command -v zoxide >/dev/null 2>&1; then
  if [ -n "${ZSH_VERSION-}" ]; then
    eval "$(zoxide init zsh)"
  elif [ -n "${BASH_VERSION-}" ]; then
    eval "$(zoxide init bash)"
  fi
fi
