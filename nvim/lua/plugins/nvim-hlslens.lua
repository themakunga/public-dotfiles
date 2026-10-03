local M = {}

local opts = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/kevinhwang91/nvim-hlslens' },
  })

  if not Checker.check('nvim-hlslens') then
    return
  end

  require('nvim-hlslens').setup(opts)
end

return M
