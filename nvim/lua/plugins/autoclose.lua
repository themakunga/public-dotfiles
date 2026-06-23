local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/m4xshen/autoclose.nvim' },
  })

  ---@module 'autoclose'
  local ok = require('utils.check-requires').check('autoclose')

  if not ok then
    return
  end

  local opts = {
    auto_indent = true,
    disabled_filetypes = { 'text' },
  }

  local autoclose = require('autoclose')

  autoclose.setup(opts)

  -- vim.keymap.set('n', '<leader>eo', '<cmd>autoclose<cr>', {desc = "Open parent directory"})
end

return M
