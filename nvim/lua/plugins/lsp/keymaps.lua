local M = {}

M.global = function()
  -- Keymaps for toggling format on save
  vim.keymap.set('n', '<leader>fd', function()
    vim.b.format_disable = true
    vim.notify('Format on save disabled for this buffer')
  end, { desc = 'Disable format on save' })

  vim.keymap.set('n', '<leader>fe', function()
    vim.b.format_disable = nil -- Use nil instead of false to remove the flag
    vim.notify('Format on save enabled for this buffer')
  end, { desc = 'Enable format on save' })
  vim.keymap.set('n', '<leader>bf', vim.lsp.buf.format, { desc = 'LSP: format current buffer' })
end

M.lspKeymapsAttached = function(buffer)
  local map = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = buffer, desc = 'LSP: ' .. desc })
  end

  local telescope = require('telescope.builtin')
  map('gd', telescope.lsp_definitions, 'Goto Definition')
  map('<leader>fs', telescope.lsp_document_symbols, 'Doc Symbols')
  map('<leader>fS', telescope.lsp_dynamic_workspace_symbols, 'Dynamic Symbols')
  map('<leader>ft', telescope.lsp_type_definitions, 'Goto Type')
  map('<leader>fr', telescope.lsp_references, 'Goto References')
  map('<leader>fi', telescope.lsp_implementations, 'Goto Impl')

  map('K', vim.lsp.buf.hover, 'hover')
  map('<leader>E', vim.diagnostic.open_float, 'diagnostic')
  map('<leader>k', vim.lsp.buf.signature_help, 'sig help')
  map('<leader>rn', vim.lsp.buf.rename, 'rename')
  map('<leader>ca', vim.lsp.buf.code_action, 'code action')
  map('<leader>wf', vim.lsp.buf.format, 'format')

  vim.keymap.set('v', '<leader>ca', vim.lsp.buf.code_action, { buffer = buffer, desc = 'Lsp: code_action' })
end

return M
