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
  vim.schedule(function()
    local status_ok, _ = pcall(vim.cmd, 'colorscheme tokyonight')
    if not status_ok then
      vim.notify('Fallo al aplicar el colorscheme tokyonight', vim.log.levels.ERROR)
    end
  end)
end

return M
