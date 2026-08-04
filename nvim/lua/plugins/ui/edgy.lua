--- Archivo: ./lua/plugins/ui/edgy.lua
local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/folke/edgy.nvim' },
  })

  local ok, edgy = pcall(require, 'edgy')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] edgy ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local opts = {
    -- Configuración del panel derecho
    right = {
      {
        title = 'NvimTree',
        ft = 'NvimTree',
        size = { height = 0.65 }, -- 65% del alto
        pinned = true, -- Siempre mantiene su lugar
      },
      {
        title = 'Trouble',
        ft = 'trouble',
        size = { height = 0.35 }, -- 35% del alto
      },
    },
    -- Opcional: animaciones más rápidas o desactivadas para mayor fluidez
    animate = {
      enabled = true,
      cps = 120,
      fps = 60,
    },
    options = {
      left_window_fault_tolerance = 1,
      right_window_fault_tolerance = 1,
    },
  }

  edgy.setup(opts)
end

return M
