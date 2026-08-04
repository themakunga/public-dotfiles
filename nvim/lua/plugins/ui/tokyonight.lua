--- Archivo: ./lua/plugins/ui/tokyonight.lua
local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/folke/tokyonight.nvim' },
  })

  -- 1. Asegurar explícitamente que los colores de GUI están activos
  vim.opt.termguicolors = true

  local ok, tokyonight = pcall(require, 'tokyonight')
  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] tokyonight ' .. debug.getinfo(2).source, vim.log.levels.WARN)
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

  tokyonight.setup(opts)

  -- 2. Posponer la aplicación del tema una fracción de milisegundo
  -- para asegurar que Neovim haya procesado el runtimepath correctamente.
  vim.schedule(function()
    local status_ok, _ = pcall(vim.cmd, 'colorscheme tokyonight')
    if not status_ok then
      vim.notify('Fallo al aplicar el colorscheme tokyonight', vim.log.levels.ERROR)
    end
  end)
end

return M
