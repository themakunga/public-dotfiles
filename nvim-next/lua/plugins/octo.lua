local M = {}

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

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/pwntester/octo.nvim' },
  })

  require('octo').setup(opts)

  KM.bulk_map({
    {
      motion = '<leader>opl',
      cmd = ':Octo pr list<CR>',
      opts = { desc = 'Octo: List PR' },
    },
    {
      motion = '<leader>opc',
      cmd = ':Octo pr create<CR>',
      opts = { desc = 'Octo: PR create' },
    },
    {
      motion = '<leader>ops',
      cmd = ':Octo pr search<CR>',
      opts = { desc = 'Octo: PR Search' },
    },
    {
      motion = '<leader>oil',
      cmd = ':Octo issue list<CR>',
      opts = { desc = 'Octo: Issues List' },
    },
    {
      motion = '<leader>oic',
      cmd = ':Octo issue create<CR>',
      opts = { desc = 'Octo: issue create' },
    },
    {
      motion = '<leader>ois',
      cmd = ':Octo issue search',
      opts = { desc = 'Octo: issues search' },
    },
  })
end

return M
