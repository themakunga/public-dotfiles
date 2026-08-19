local M = {}

M.plugin = function()

  vim.pack.add({
    { src = 'https://github.com/folke/tokyonight.nvim' },
  })

  vim.opt.termguicolors = true

  local ok = require('utils.checker').check('tokyonight')

  if not ok then return end

  local opts = {
    style = 'storm',
    transparent = true,
    styles = {
      floats = 'transparent',
      sidebars = 'transparent',
    },
  }


  tokyonight.setup(opts)

  vim.schedule(function()
    local status_ok, _ = pcall(vim.cmd, 'colorscheme tokyonight')
    if not status_ok then
      vim.notify('[COLORSCHEME - tokyonight] failed to apply', vim.log.levels.ERROR)
    end
  end)

end

return M
