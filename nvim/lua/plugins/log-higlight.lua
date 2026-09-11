local M = {}

local opts = {
  pattern = {
    '.*%.log%..*',
    '.*%.log%d+',
    '.*%.log%d+%.?gz?',
  },
}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/fei6409/log-highlight.nvim' },
  })

  if not Checker.check('log-highlight') then
    return
  end

  require('log-highlight').setup(opts)
end

return M
