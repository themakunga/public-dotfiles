local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/pwntester/octo.nvim' },
  })

  if not Checker.check('octo') then
    return
  end
end

return M
