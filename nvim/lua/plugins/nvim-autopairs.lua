local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/windwp/nvim-autopairs' },
  })

  if not Checker.check('nvim-autopairs') then
    return
  end

  require('nvim-autopairs').setup({})
end

return M
