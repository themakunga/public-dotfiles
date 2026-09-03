local M = {}

local function apply_highlight()
  local c = function()
    local palette = require('tokyonight.colors').setup({ style = 'storm' })

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

  return c
end

local colors = apply_highlight()
local mode_colors = {
  n = colors.red,
  i = colors.green,
  v = colors.blue,
  [''] = colors.blue,
  V = colors.blue,
  c = colors.magenta,
  no = colors.red,
  s = colors.orange,
  S = colors.orange,
  [''] = colors.orange,
  ic = colors.yellow,
  R = colors.violet,
  Rv = colors.violet,
  cv = colors.red,
  ce = colors.red,
  r = colors.cyan,
  rm = colors.cyan,
  ['r?'] = colors.cyan,
  ['!'] = colors.red,
  t = colors.red,
}

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
}

local config = {
  options = {
    component_separators = '',
    section_separators = '',
    theme = {
      normal = { c = 'LualineNormalC' },
      inactive = { c = 'LualineInactiveC' },
    },
  },
  sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
}

local function ins_left(components)
  for _, c in ipairs(components) do
    table.insert(config.sections.lualine_c, c)
  end
end

local function ins_right(components)
  for _, c in ipairs(components) do
    table.insert(config.sections.lualine_x, c)
  end
end

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
    { src = 'https://github.com/nvim-lualine/lualine.nvim' },
    { src = 'https://github.com/folke/tokyonight.nvim' },
  })

  if not Checker.check('lualine') then
    return
  end

  ins_left({
    {
      'mode',
      fmt = function(str)
        return ' ' .. str
      end,
      color = function()
        local current_mode = vim.fn.mode()
        local m_color = mode_colors[current_mode] or mode_colors[current_mode:sub(1, 1)] or colors.blue
        return { bg = colors.bg, fd = m_color, gui = 'bold' }
      end,
      padding = { right = 1 },
    },
    {
      'diagnostics',
      source = { 'nvim_diagnostic' },
      symbols = { error = ' ', warn = ' ', info = ' ' },
      diagnostics_color = {
        error = 'LualineDiagnosticsError',
        warn = 'LualineDiagnosticsWarn',
        info = 'LualineDiagnosticsInfo',
      },
    },
    {
      function()
        return '%='
      end,
    },
  })

  ins_right({
    {
      function()
        return '%='
      end,
    },
    {
      function()
        local msg = ''
        local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
        local clients = vim.lsp.get_clients()
        if next(clients) == nil then
          return msg
        end
        for _, client in ipairs(clients) do
          if client.config.filetypes and vim.fn.index(client.config.filetypes, buf_ft) ~= -1 then
            return client.name
          end
        end
        return msg
      end,
      icon = '󰧑',
      color = 'LualineLsp',
    },
    {
      'branch',
      icon = '',
      color = 'LualineBranch',
    },
    {
      'diff',
      symbols = { added = ' ', modified = ' ', removed = ' ' },
      diff_color = {
        added = 'LualineDiffAdded',
        modified = 'LualineDiffModified',
        removed = 'LualineDiffRemoved',
      },
      cond = conditions.hide_in_width,
    },
    {
      function()
        return os.date('%H:%M')
      end,
      icon = '',
      color = 'LualineDiagnosticsWarn',
    },
  })

  require('lualine').setup(config)
end

return M
