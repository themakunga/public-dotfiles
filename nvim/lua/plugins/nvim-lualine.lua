local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-lualine/lualine.nvim' },
  })

  if not Checker.check('lualine') then
    return
  end

  -- Tokyo Night Moon — mismos colores que tmux
  local c = {
    bg      = '#222436',
    fg      = '#c8d3f5',
    gray    = '#3a3f5a',
    dark    = '#444a73',
    blue    = '#82aaff',
    green   = '#c3e88d',
    magenta = '#c099ff',
    red     = '#ff757f',
    yellow  = '#ffc777',
    black   = '#1b1d2b',
  }

  local theme = {
    normal   = { a = { fg = c.black, bg = c.blue,    gui = 'bold' }, b = { fg = c.fg, bg = c.bg }, c = { fg = c.fg, bg = c.bg } },
    insert   = { a = { fg = c.black, bg = c.green,   gui = 'bold' }, b = { fg = c.fg, bg = c.bg }, c = { fg = c.fg, bg = c.bg } },
    visual   = { a = { fg = c.black, bg = c.magenta, gui = 'bold' }, b = { fg = c.fg, bg = c.bg }, c = { fg = c.fg, bg = c.bg } },
    replace  = { a = { fg = c.black, bg = c.red,     gui = 'bold' }, b = { fg = c.fg, bg = c.bg }, c = { fg = c.fg, bg = c.bg } },
    command  = { a = { fg = c.black, bg = c.yellow,  gui = 'bold' }, b = { fg = c.fg, bg = c.bg }, c = { fg = c.fg, bg = c.bg } },
    inactive = { a = { fg = c.fg,    bg = c.dark                  }, b = { fg = c.fg, bg = c.bg  }, c = { fg = c.fg, bg = c.bg } },
  }

  -- Cwd: últimos 2 segmentos como tmux (rev | cut -d'/' -f-2 | rev)
  local function cwd_2()
    local parts = vim.split(vim.fn.getcwd(), '/', { plain = true })
    local n = #parts
    local path = n >= 2 and (parts[n - 1] .. '/' .. parts[n]) or (parts[n] or '')
    return '󰉖 ' .. path
  end

  require('lualine').setup({
    options = {
      theme                = theme,
      section_separators   = { left = '', right = '' }, -- píldora/bubble
      component_separators = { left = '', right = '' },
      globalstatus         = true,
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = {
        { 'branch', color = { fg = c.blue,  bg = c.bg } },
        { 'diff',   color = { fg = c.fg,    bg = c.bg } },
      },
      lualine_c = { { 'filename', path = 1 } },
      lualine_x = { 'diagnostics' },
      lualine_y = { 'filetype' },
      lualine_z = { { cwd_2, color = { fg = c.black, bg = c.magenta, gui = 'bold' } } },
    },
    inactive_sections = {
      lualine_c = { { 'filename', path = 1 } },
      lualine_x = { 'location' },
    },
  })
end

return M
