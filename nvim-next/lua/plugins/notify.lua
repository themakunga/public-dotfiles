local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/rcarriga/nvim-notify' },
  })

  if not Checker.check('notify') then
    return
  end

  local notify = require('notify')

  local opts = {
    background_colour = '#000000',
    stages = 'fade',
    timeout = 3000,
    max_width = 50,
  }

  notify.setup(opts)

  vim.notify = notify
end

return M
