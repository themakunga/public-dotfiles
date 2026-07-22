local M = {}

M.plugin = function()
  vim.pack.add({
    {
      src = 'https://github.com/pwntester/octo.nvim',
    },
  })

  local checklist = {
    'octo',
    'telescope',
  }

  local ok = require('utils.check-requires').check(checklist)

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] octo ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local octo = require('octo')
  local telescope = require('telescope')

  local opts = {
    picker = 'telescope', -- <--- AQUÍ LE INDICAMOS QUE USE TELESCOPE
    enable_builtin = true,
    default_remote = { 'upstream', 'origin' },
    pull_requests = {
      order_by = {
        field = 'CREATED_AT',
        direction = 'DESC',
      },
      always_select_remote_on_create = false,
    },
    ui = {
      use_signcolumn = true,
    },
  }

  octo.setup(opts)

  telescope.load_extension('octo')
  local map = vim.keymap.set
  map('n', '<leader>opl', '<cmd>Octo pr list<CR>', { desc = 'Octo: List PRs', silent = true })
  map('n', '<leader>opc', '<cmd>Octo pr create<CR>', { desc = 'Octo: Create PR', silent = true })
  map('n', '<leader>ops', '<cmd>Octo pr search<CR>', { desc = 'Octo: Search PRs', silent = true })
  map('n', '<leader>oil', '<cmd>Octo issue list<CR>', { desc = 'Octo: List Issues', silent = true })
  map('n', '<leader>oic', '<cmd>Octo issue create<CR>', { desc = 'Octo: Create Issue', silent = true })
  map('n', '<leader>ois', '<cmd>Octo issue search<CR>', { desc = 'Octo: Search Issues', silent = true })
  map('n', '<leader>otp', '<cmd>Telescope octo prs<CR>', { desc = 'Telescope: Active PRs', silent = true })
  map('n', '<leader>oti', '<cmd>Telescope octo issues<CR>', { desc = 'Telescope: Active Issues', silent = true })
  map('n', '<leader>ors', '<cmd>Octo review start<CR>', { desc = 'Octo: Start review', silent = true })
  map('n', '<leader>orm', '<cmd>Octo review submit<CR>', { desc = 'Octo: Submit review', silent = true })
  map('n', '<leader>orc', '<cmd>Octo review close<CR>', { desc = 'Octo: Cancel review', silent = true })
end

return M
