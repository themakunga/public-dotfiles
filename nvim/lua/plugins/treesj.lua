local M = {}

local opts = {
  use_default_keymaps = false,
}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/wansmer/treesj' },
  })

  if not Checker.check('treesj') then
    return
  end

  require('treesj').setup(opts)

  KM.map({
    mode = 'n',
    motion = '<leader>m',
    cmd = require('treesj').toggle,
    opts = { desc = 'Toggle TreeSJ' },
  })
end

return M
