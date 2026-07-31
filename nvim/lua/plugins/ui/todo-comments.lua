local M = {}

M.plugin = function()
  -- Este plugin requiere 'plenary.nvim' como dependencia.
  -- Si ya lo tienes en otro módulo, puedes omitirlo de este bloque de pack.add.
  vim.pack.add({
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/folke/todo-comments.nvim' },
  })

  local ok, todo_comments = pcall(require, 'todo-comments')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] todo_comments ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local opts = {
    -- Puedes ajustar los signos (iconos en la columna de la izquierda)
    signs = true,
    keywords = {
      -- Las palabras clave por defecto incluyen FIX, TODO, HACK, WARN, PERF, NOTE, TEST
      -- Aquí añadimos 'DEBUG' personalizado, ya que lo mencionaste
      DEBUG = {
        icon = ' ', -- Icono que aparecerá junto al comentario
        color = 'warning', -- Color del resaltado (puede ser hex, ej: "#FFA500")
        alt = { 'debug' }, -- Variantes de la palabra que también se resaltarán
      },
    },
    -- Configuración visual del resaltado
    highlight = {
      multiline = true, -- Resalta comentarios de múltiples líneas
      keyword = 'wide', -- "wide" resalta el fondo, "fg" solo el texto
      pattern = [[.*<(KEYWORDS)\s*:]], -- Patrón regex que busca "NOTA:" o "debug:"
    },
  }

  todo_comments.setup(opts)

  -- Mapeos útiles
  -- Salta rápidamente al siguiente o anterior comentario de este tipo
  vim.keymap.set('n', ']t', function()
    todo_comments.jump_next()
  end, { desc = 'Siguiente todo/note/debug comment' })

  vim.keymap.set('n', '[t', function()
    todo_comments.jump_prev()
  end, { desc = 'Anterior todo/note/debug comment' })
end

return M
