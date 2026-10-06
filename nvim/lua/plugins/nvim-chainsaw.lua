local M = {}

local opts = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/chrisgrieser/nvim-chainsaw' },
  })

  if not Checker.check('chainsaw') then
    return
  end

  require('chainsaw').setup(opts)

  KM.map({
    mode = 'n',
    motion = '<leader>cL',
    cmd = require('chainsaw').variableLog,
    opts = { desc = 'Log variable' },
  })
end

return M
