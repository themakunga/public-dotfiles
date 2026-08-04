--- Archivo: ./lua/plugins/ui/todo-comments.lua
local M = {}

M.plugin = function()
  -- ELIMINADO: plenary.nvim (ya está en dependencias globales)
  vim.pack.add({
    { src = 'https://github.com/folke/todo-comments.nvim' },
  })

  local ok, todo_comments = pcall(require, 'todo-comments')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] todo-comments ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local opts = {
    signs = true,
    keywords = {
      DEBUG = {
        icon = ' ',
        color = 'warning',
        alt = { 'debug' },
      },
    },
    highlight = {
      multiline = true,
      keyword = 'wide',
      pattern = [[.*<(KEYWORDS)\s*:]],
    },
  }

  todo_comments.setup(opts)

  vim.keymap.set('n', ']t', function()
    todo_comments.jump_next()
  end, { desc = 'Siguiente todo/note/debug comment' })
  vim.keymap.set('n', '[t', function()
    todo_comments.jump_prev()
  end, { desc = 'Anterior todo/note/debug comment' })
end

return M
