local M = {}

local opts = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/harrisoncramer/gitlab.nvim' },
  })

  if not Checker.check('gitlab') then
    return
  end

  require('gitlab').setup(opts)
end

return M
