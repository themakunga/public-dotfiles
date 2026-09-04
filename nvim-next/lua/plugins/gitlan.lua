local M = {}

local opts = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/harrisoncramer/gitlab.nvim' },
  })

  if not Checker.check('gitlab') then
    return
  end

  require('gitlan').setup(opts)
end

return M
