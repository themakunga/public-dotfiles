--- Archivo: ./lua/plugins/git/lazygit.lua
local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/kdheepak/lazygit.nvim' },
  })

  local ok, lazygit = pcall(require, 'lazygit')
  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] lazygit ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end
  -- Configuración opcional aquí
end

-- Este mapeo DEBE ir fuera de M.plugin para que exista siempre,
-- y se encarga de cargar el plugin internamente cuando lo usas.
vim.keymap.set('n', '<leader>glg', function()
  -- Verificamos si ya está cargado, si no, lo cargamos
  if not package.loaded['lazygit'] then
    M.plugin()
  end
  vim.cmd('LazyGit')
end, { desc = 'Open LazyGit (Lazy Loaded)' })

return M
