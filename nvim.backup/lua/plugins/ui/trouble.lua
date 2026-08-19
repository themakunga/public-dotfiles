local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/folke/trouble.nvim' },
  })

  ---@module 'trouble'
  local ok, trouble = pcall(require, 'trouble')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] trouble ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local opts = {}

  trouble.setup(opts)

  -- Keymaps
  vim.keymap.set('n', '<leader>cD', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Diagnostics (Trouble)' })
  vim.keymap.set(
    'n',
    '<leader>cd',
    '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
    { desc = 'Buffer Diagnostics (Trouble)' }
  )
  vim.keymap.set('n', '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', { desc = 'Document Symbols' })
  vim.keymap.set(
    'n',
    '<leader>cl',
    '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
    { desc = 'LSP Definitions / references / ... (Trouble)' }
  )
  vim.keymap.set('n', '<leader>cL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Location List (Trouble)' })
  vim.keymap.set('n', '<leader>cQ', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quickfix List (Trouble)' })
end

return M
