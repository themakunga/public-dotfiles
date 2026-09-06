local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/folke/snacks.nvim' },
  })

  if not Checker.check('snacks') then
    return
  end

  local opts = {
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    styles = {
      notification = {},
    },
  }

  local snacks = require('snacks')
  snacks.setup(opts)

  KM.map({
    mode = 'n',
    motion = '<leader>n',
    cmd = function()
      snacks.notifier.show_history()
    end,
    opts = { desc = 'Show notification history' },
  })
end

return M
