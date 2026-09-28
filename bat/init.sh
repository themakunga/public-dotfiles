# Interactive shells only: scripts continue to use the system cat.
if command -v bat >/dev/null 2>&1; then
  if [ "${XDG_CONFIG_HOME:-$HOME/.config}/bat/themes/tokyonight_night.tmTheme" -nt "${XDG_CACHE_HOME:-$HOME/.cache}/bat/themes.bin" ]; then
    bat cache --build >/dev/null
  fi
  alias cat='bat --paging=never'
fi
