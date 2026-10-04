local M = {}

local opts = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/mawkler/modicator.nvim' },
  })

  if not Checker.check('modicator') then
    return
  end

  local o = vim.o

  o.cursorline = true
  o.number = true
  o.termguicolors = true

  require('modicator').setup(opts)
end

return M
