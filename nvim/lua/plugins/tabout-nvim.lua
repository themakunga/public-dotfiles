local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/abecodes/tabout.nvim' },
  })

  if not Checker.check('tabout') then
    return
  end

  require('tabout').setup({})
end

return M
