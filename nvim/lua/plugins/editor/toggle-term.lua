local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/akinsho/toggleterm.nvim' },
  })

  --@module 'toggleterm'
  local ok, toggleterm = pcall(require, 'toggleterm')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] toggleterm ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  --@type toggleterm.SetupOps
  local opts = {
    direction = 'float',
    close_on_exit = false,

    -- NUEVA CONFIGURACIÓN:
    start_in_insert = true, -- Fuerza a que siempre inicie lista para escribir
    persist_mode = false, -- Evita que recuerde el modo Normal al ocultarla

    float_opts = {
      border = 'curved',
    },
  }

  toggleterm.setup(opts)

  vim.keymap.set('n', '<A-t>', '<cmd>ToggleTerm direction=float<cr>', { desc = 'Toggle Terminal' })

  -- Se limpió el espacio extra y se unificó usando <cmd>
  vim.keymap.set('t', '<A-t>', '<C-\\><C-n><cmd>ToggleTerm<CR>', { desc = 'Hide Terminal' })
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n><cmd>ToggleTerm<CR>', { desc = 'Hide Terminal' })
end

return M
