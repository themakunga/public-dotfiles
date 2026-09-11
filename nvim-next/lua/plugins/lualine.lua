local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
    { src = 'https://github.com/nvim-lualine/lualine.nvim' },
  })

  ---@module 'lualine'
  local ok_lualine, lualine = pcall(require, 'lualine')
  if not ok_lualine then
    Log.warn('[lualine] require failed ' .. debug.getinfo(2).source)
    return
  end

  -- El módulo de tema vive en plugins/lualine-theme.lua (mismo nivel)
  local ok_theme, lualine_theme = pcall(require, 'plugins.lualine-theme')
  if not ok_theme then
    Log.warn('[lualine-theme] require failed ' .. debug.getinfo(2).source)
    return
  end

  -- Aplica los highlight groups DESPUÉS de que el colorscheme esté activo
  lualine_theme.apply_highlights()

  -- Construye la paleta y el mapa modo→color UNA vez
  -- (el componente mode_color se ejecuta en cada cursor-move / mode-change)
  local colors = lualine_theme.build_theme()
  local mode_color = {
    n      = colors.red,
    i      = colors.green,
    v      = colors.blue,
    ['']  = colors.blue,
    V      = colors.blue,
    c      = colors.magenta,
    no     = colors.red,
    s      = colors.orange,
    S      = colors.orange,
    [''] = colors.orange,
    ic     = colors.yellow,
    R      = colors.violet,
    Rv     = colors.violet,
    cv     = colors.red,
    ce     = colors.red,
    r      = colors.cyan,
    rm     = colors.cyan,
    ['r?'] = colors.cyan,
    ['!']  = colors.red,
    t      = colors.red,
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
      section_separators   = '',
      theme = {
        -- Usamos lualine_c y lualine_x como secciones izquierda y derecha.
        -- Ambas se colorean con el theme "c".
        normal   = { c = 'LualineNormalC' },
        inactive = { c = 'LualineInactiveC' },
      },
    },
    sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_y = {},
      lualine_z = {},
      lualine_c = {}, -- izquierda (rellenado abajo)
      lualine_x = {}, -- derecha  (rellenado abajo)
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_y = {},
      lualine_z = {},
      lualine_c = {},
      lualine_x = {},
    },
  }

  local function ins_left(component)
    table.insert(config.sections.lualine_c, component)
  end

  local function ins_right(component)
    table.insert(config.sections.lualine_x, component)
  end

  -- ── Sección izquierda ────────────────────────────────────────────────────

  ins_left({
    'mode',
    fmt = function(str)
      return ' ' .. str
    end,
    color = function()
      local m = vim.fn.mode()
      local fg = mode_color[m] or mode_color[m:sub(1, 1)] or colors.blue
      return { bg = colors.bg, fg = fg, gui = 'bold' }
    end,
    padding = { right = 1 },
  })

  ins_left({
    'filename',
    cond  = conditions.buffer_not_empty,
    color = 'LualineFilename',
  })

  ins_left({
    'diagnostics',
    sources = { 'nvim_diagnostic' },
    symbols = { error = ' ', warn = ' ', info = ' ' },
    diagnostics_color = {
      error = 'LualineDiagnosticsError',
      warn  = 'LualineDiagnosticsWarn',
      info  = 'LualineDiagnosticsInfo',
    },
  })

  -- Separador central (empuja la sección derecha al extremo)
  ins_left({
    function() return '%=' end,
  })

  -- ── Sección derecha ──────────────────────────────────────────────────────

  ins_right({
    function()
      local buf_ft  = vim.api.nvim_get_option_value('filetype', { buf = 0 })
      local clients = vim.lsp.get_clients()
      if next(clients) == nil then return '' end
      for _, client in ipairs(clients) do
        local fts = client.config.filetypes
        if fts and vim.fn.index(fts, buf_ft) ~= -1 then
          return client.name
        end
      end
      return ''
    end,
    icon  = '󰧑',
    color = 'LualineLsp',
  })

  ins_right({
    'branch',
    icon  = '',
    color = 'LualineBranch',
  })

  ins_right({
    'diff',
    symbols   = { added = ' ', modified = ' ', removed = ' ' },
    diff_color = {
      added    = 'LualineDiffAdded',
      modified = 'LualineDiffModified',
      removed  = 'LualineDiffRemoved',
    },
    cond = conditions.hide_in_width,
  })

  ins_right({
    function() return os.date('%H:%M') end,
    icon  = '',
    color = 'LualineDiagnosticsWarn',
  })

  lualine.setup(config)
end

return M
