local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-zh/colorful-winsep.nvim' },
  })

  if not Checker.check('colorful-winsep') then
    return
  end

  require('colorful-winsep').setup({
    border = 'rounded',
    animate = { enabled = false },
    indicator_for_2wins = { position = false },
    highlight = function()
      local colors = require('tokyonight.colors').setup()
      vim.api.nvim_set_hl(0, 'ColorfulWinSep', { fg = colors.blue, bg = 'NONE' })
    end,
  })
end

return M
