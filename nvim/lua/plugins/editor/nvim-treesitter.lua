--- Archivo: ./lua/plugins/editor/nvim-treesitter.lua
local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },
  })

  ---@module 'treesitter-context'
  local ok, tsc = pcall(require, 'treesitter-context')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] treesitter-context ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  -- Show context of the current function
  local opts = {
    mode = 'cursor',
    max_lines = 3,
  }

  tsc.setup(opts)

  local function toggle_treesitter_context()
    if tsc.enabled then
      tsc.disable()
    else
      tsc.enable()
    end
  end

  -- Converted to vim.keymap.set so the local function works correctly in this scope
  vim.keymap.set(
    'n',
    '<leader>ut',
    toggle_treesitter_context,
    { noremap = true, silent = true, desc = 'Toggle Treesitter Context' }
  )
end

return M
