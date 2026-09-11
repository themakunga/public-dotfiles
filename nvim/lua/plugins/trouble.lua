local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/folke/trouble.nvim' },
  })

  if not Checker.check('trouble') then
    return
  end

  require('trouble').setup()

  KM.bulk_map({
    {
      motion = '<leader>xx',
      cmd = ':Trouble diagnostics toggle<CR>',
      opts = { desc = 'Diagnostics (Trouble)' },
    },
    {
      motion = '<leader>xX',
      cmd = ':Trouble diagnostics toggle filter.buf=0<CR>',
      opts = { desc = 'Buffer Diagnostics (Trouble)' },
    },
    {
      motion = '<leader>cs',
      cmd = ':Trouble symbols toggle focus=false<CR>',
      opts = { desc = 'Symbols (Trouble)' },
    },
    {
      motion = '<leader>cl',
      cmd = ':Trouble lsp toggle focus=false win.position=right<CR>',
      opts = { desc = 'LSP Definitions / references / ... (Trouble' },
    },
    {
      motion = '<leader>xL',
      cmd = ':Trouble loclist toggle<CR>',
      opts = { desc = 'Location List (Trouble)' },
    },
    {
      motion = '<leader>xQ',
      cmd = ':Trouble qflist toggle<CR>',
      opts = { desc = 'Quickfix List (Trouble)' },
    },
  })
end

return M
