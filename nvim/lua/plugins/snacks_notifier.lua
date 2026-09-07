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
      -- Terminal flotante a la izquierda (usado por claudecode con provider = "snacks")
      terminal = {
        position = 'float',
        relative = 'editor',
        border = 'rounded',
        width = 0.38,
        height = 0.90,
        row = 0,
        col = 0,
        zindex = 50,
      },
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
