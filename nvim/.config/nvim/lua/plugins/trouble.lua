local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/folke/trouble.nvim' },
  })
  local ok, trouble = pcall(require, 'trouble')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] trouble ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  trouble.setup()

  local map = vim.keymap.set
  map('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Diagnostics (Trouble)' })
  map('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', { desc = 'Buffer Diagnostics (Trouble)' })
  map('n', '<leader>cs', '<cmd>Trouble symbols toggle focus=false<CR>', { desc = 'Symbols (Trouble)' })
  map(
    'n',
    '<leader>cl',
    '<cmd>Trouble lsp toggle focus=false win.position=right<CR>',
    { desc = 'LSP Definitions / references / ... (Trouble)' }
  )

  map('n', '<leader>xL', '<cmd>Trouble loclist toggle<CR>', { desc = 'Location List (Trouble)' })
  map('n', '<leader>xQ', '<cmd>Trouble qflist toggle<CR>', { desc = 'Quickfix List (Trouble)' })
end

return M
