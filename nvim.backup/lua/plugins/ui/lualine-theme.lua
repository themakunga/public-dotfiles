local M = {}

local function get_palette()
 local ok, tokyonight_colors = pcall(require, 'tokyonight.colors')

  if not ok then
    return {}
  end

  -- Carga los colores basados en el estilo 'storm'
  local palette = tokyonight_colors.setup({ style = 'storm' })

  return {
    bg = palette.bg,
    fg = palette.fg,
    yellow = palette.yellow,
    cyan = palette.cyan,
    darkblue = palette.bg_dark,
    green = palette.green,
    orange = palette.orange,
    violet = palette.purple,
    magenta = palette.magenta,
    blue = palette.blue,
    red = palette.red,
    pink = palette.magenta2 or palette.magenta,
  }
end

function M.build_theme()
  return get_palette()
end

function M.apply_highlights()
  local c = get_palette()

  if not c.bg then
    return
  end

  vim.api.nvim_set_hl(0, 'LualineNormalC', { fg = c.fg, bg = c.bg })
  vim.api.nvim_set_hl(0, 'LualineInactiveC', { fg = c.fg, bg = c.bg })
  vim.api.nvim_set_hl(0, 'LualineFilename', { fg = c.fg, bg = c.bg })

  vim.api.nvim_set_hl(0, 'LualineDiagnosticsError', { bg = c.bg, fg = c.red })
  vim.api.nvim_set_hl(0, 'LualineDiagnosticsWarn', { bg = c.bg, fg = c.yellow })
  vim.api.nvim_set_hl(0, 'LualineDiagnosticsInfo', { bg = c.bg, fg = c.cyan })
  vim.api.nvim_set_hl(0, 'LualineLsp', { bg = c.bg, fg = c.pink })
  vim.api.nvim_set_hl(0, 'LualineBranch', { bg = c.bg, fg = c.violet, bold = true })
  vim.api.nvim_set_hl(0, 'LualineDiffAdded', { bg = c.bg, fg = c.green, bold = true })
  vim.api.nvim_set_hl(0, 'LualineDiffModified', { bg = c.bg, fg = c.orange, bold = true })
  vim.api.nvim_set_hl(0, 'LualineDiffRemoved', { bg = c.bg, fg = c.red, bold = true })
end

return M
