local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/themakunga/tennant.nvim' },
  })

  -- For local development, uncomment and point to local path:
  -- vim.opt.runtimepath:prepend('/Users/nicolas/Projects/personal/tennant.nvim')

  if not Checker.check('tennant') then
    return
  end

  require('tennant').setup({
    prefix = '<leader>tv',
  })
end

return M
