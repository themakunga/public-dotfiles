local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/folke/tokyonight.nvim' },
  })

  if not Checker.check('tokyonight') then
    return
  end

  local opts = {
    style = 'storm',
    transparent = true,
    styles = {
      floats = 'transparent',
      sidebars = 'transparent',
    },
  }

  require('tokyonight').setup(opts)
  vim.cmd('colorscheme tokyonight')
end

return M
