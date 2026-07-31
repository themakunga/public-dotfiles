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
    -- Configuramos específicamente el panel derecho
    right = {
      -- 1. NvimTree arriba a la derecha
      {
        title = 'NvimTree',
        ft = 'NvimTree',
        size = { height = 0.75 }, -- Ocupa el 50% del espacio vertical
        pinned = true, -- Mantiene la posición
      },
      -- 2. Trouble (Errores) abajo a la derecha
      {
        title = 'Trouble',
        ft = 'trouble',
        size = { height = 0.25 }, -- Ocupa el 50% restante
      },
    },
    -- Otras opciones de edgy (opcionales)
    options = {
      left_window_fault_tolerance = 1,
      right_window_fault_tolerance = 1,
    },
  }

  edgy.setup(opts)
end

return M
