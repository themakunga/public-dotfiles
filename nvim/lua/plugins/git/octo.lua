--- Archivo: ./lua/plugins/git/octo.lua
local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/pwntester/octo.nvim' },
  })

  local ok, octo = pcall(require, 'octo')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] octo ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local opts = {
    picker = 'fzf-lua', -- <-- Cambiado a fzf-lua
    enable_builtin = true,
    default_remote = { 'upstream', 'origin' },
    pull_requests = {
      order_by = { field = 'CREATED_AT', direction = 'DESC' },
      always_select_remote_on_create = false,
    },
    ui = { use_signcolumn = true },
  }

  octo.setup(opts)

  local map = vim.keymap.set
  map('n', '<leader>opl', '<cmd>Octo pr list<CR>', { desc = 'Octo: List PRs', silent = true })
  map('n', '<leader>opc', '<cmd>Octo pr create<CR>', { desc = 'Octo: Create PR', silent = true })
  map('n', '<leader>ops', '<cmd>Octo pr search<CR>', { desc = 'Octo: Search PRs', silent = true })
  map('n', '<leader>oil', '<cmd>Octo issue list<CR>', { desc = 'Octo: List Issues', silent = true })
  map('n', '<leader>oic', '<cmd>Octo issue create<CR>', { desc = 'Octo: Create Issue', silent = true })
  map('n', '<leader>ois', '<cmd>Octo issue search<CR>', { desc = 'Octo: Search Issues', silent = true })
  -- Actualizados los mapeos que dependían de Telescope
  map('n', '<leader>otp', '<cmd>Octo pr list<CR>', { desc = 'Octo: Active PRs', silent = true })
  map('n', '<leader>oti', '<cmd>Octo issue list<CR>', { desc = 'Octo: Active Issues', silent = true })
end

return M
