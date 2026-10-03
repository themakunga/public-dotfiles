local M = {}

local opts = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/mawkler/modificator.nvim' },
  })

  if not Checker.check('modificator') then
    return
  end

  local o = vim.o

  o.cursorline = true
  o.number = true
  o.termguicolors = true

  require('modificator').setup(opts)
end

return M
