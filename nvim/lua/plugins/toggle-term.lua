local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/akinsho/toggleterm.nvim' },
  })

  if not Checker.check('toggleterm') then
    return
  end

  local opts = {
    direction = 'float',
    close_on_exit = false,
    start_in_insert = true,
    persist_mode = false,

    float_opts = {
      border = 'curved', -- Bordes redondeados ('curved' es el equivalente en toggleterm)

      width = math.floor(vim.o.columns * 0.95), -- 95% del ancho de la pantalla
      height = math.floor(vim.o.lines * 0.3), -- 30% del alto de la pantalla

      row = math.floor(vim.o.lines * 0.9),
      col = math.floor(vim.o.columns * 0.025), -- Centrado horizontalmente
    },
  }

  require('toggleterm').setup(opts)

  KM.bulk_map({
    { mode = 'n', motion = '<A-t>', cmd = '<cmd>ToggleTerm<cr>', opts = { desc = 'Toggle Terminal' } },
    { mode = 't', motion = '<A-t>', cmd = '<C-\\><C-n><cmd>ToggleTerm<CR>', opts = { desc = 'Hide Terminal' } },
    { mode = 't', motion = '<Esc><Esc>', cmd = '<C-\\><C-n><cmd>ToggleTerm<CR>', opts = { desc = 'Hide Terminal' } },
  })
end

return M
