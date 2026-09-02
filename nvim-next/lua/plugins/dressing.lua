local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/stevearc/dressing.nvim' },
  })

  if not Checker.check("dressing") then
    return
  end

  require("dressing").setup({})
end

return M

