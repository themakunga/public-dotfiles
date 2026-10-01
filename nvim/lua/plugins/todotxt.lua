local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/phrmendes/todotxt.nvim' },
  })

  if not Checker.check({ 'todotxt' }) then
    return
  end

  require('todotxt').setup({})
end

return M
