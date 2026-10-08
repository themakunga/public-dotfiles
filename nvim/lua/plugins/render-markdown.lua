local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },
  })

  if not Checker.check('render-markdown') then
    return
  end

  require('render-markdown').setup({})
end

return M
