local M = {}

local config = require('plugins.nvim-treesitter.config')

local function setup_buffer(event)
  local bufnr = event.buf

  local filetype = vim.bo[bufnr].filetype

  local language = vim.treesitter.language.get_lang(filetype)

  if not language then
    return
  end

  -- highlight

  local started = pcall(vim.treesitter.start, bufnr, language)

  if not started then
    return
  end

  -- indentation
  local has_indent_query, query = pcall(vim.treesitter.query.get, language, 'indents')

  if has_indent_query and query then
    vim.bo[bufnr].indentexpr = 'v:lua.require\'nvim-treesitter\'.indentexpr()'
  end
end

M.setup = function()
  CMD.aucmd('TreesitterFeatures', {
    {
      event = 'FileType',
      pattern = config.filetypes,
      callback = setup_buffer,
    },
  })
end

return M
