local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/rachartier/tiny-cmdline.nvim' },
  })

  if not Checker.check('tiny-cmdline.') then
    return
  end
  local opts = {
    on_reposition = require('tiny-cmdline.').adapters.blink,
    with = {
      value = '70%',
    },
  }

  require('vim._core.ui2').enable({})

  vim.o.cmdheight = 0

  require('tiny-cmdline.').setup(opts)
end

return M
