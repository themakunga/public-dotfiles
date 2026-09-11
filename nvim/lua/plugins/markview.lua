local M = {}

local opts = {
  preview = {
    icon_provider = 'mini', -- "mini" or "devicons"
  },
}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/OXY2DEV/markview.nvim' },
  })

  if not Checker.check('markview') then
    return
  end

  require('markview').setup(opts)
end

return M
