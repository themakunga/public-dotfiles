-- lualine-theme.lua
-- Paleta estática alineada con tokyonight-storm.
-- Se usa "estática" para evitar problemas de orden de carga.
-- Si cambias de colorscheme, actualiza PALETTE.

local M = {}

-- Colores base de tokyonight-storm
local PALETTE = {
  bg       = '#1f2335', -- bg_statusline de storm
  fg       = '#c0caf5',
  red      = '#f7768e',
  green    = '#9ece6a',
  blue     = '#7aa2f7',
  magenta  = '#bb9af7',
  orange   = '#ff9e64',
  yellow   = '#e0af68',
  violet   = '#9d7cd8',
  cyan     = '#7dcfff',
  inactive = '#565f89', -- comment color (para estado inactivo)
  -- Git diff
  diff_add    = '#449dab',
  diff_change = '#6183bb',
  diff_delete = '#914c54',
}

--- Devuelve la paleta de colores para uso en lualine.lua
---@return table
function M.build_theme()
  return PALETTE
end

--- Define todos los highlight groups personalizados usados por lualine.
--- Llamar después de que el colorscheme esté activo.
function M.apply_highlights()
  local p = PALETTE
  local hl = function(name, opts)
    vim.api.nvim_set_hl(0, name, opts)
  end

  -- Statusline base
  hl('LualineNormalC',   { bg = p.bg,   fg = p.fg })
  hl('LualineInactiveC', { bg = 'NONE', fg = p.inactive })

  -- Componentes
  hl('LualineFilename', { bg = p.bg, fg = p.blue, bold = true })
  hl('LualineLsp',      { bg = p.bg, fg = p.magenta })
  hl('LualineBranch',   { bg = p.bg, fg = p.orange })

  -- Diagnósticos
  hl('LualineDiagnosticsError', { bg = p.bg, fg = p.red })
  hl('LualineDiagnosticsWarn',  { bg = p.bg, fg = p.yellow })
  hl('LualineDiagnosticsInfo',  { bg = p.bg, fg = p.cyan })

  -- Diff
  hl('LualineDiffAdded',    { bg = p.bg, fg = p.diff_add })
  hl('LualineDiffModified', { bg = p.bg, fg = p.diff_change })
  hl('LualineDiffRemoved',  { bg = p.bg, fg = p.diff_delete })
end

return M
