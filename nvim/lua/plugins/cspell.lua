local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/neovim/nvim-lspconfig' },
  })

  if not Checker.check({ 'lspconfig' }) then
    return
  end

  local lspconfig = require('lspconfig')

  lspconfig.cspell.setup({
    filetypes = { 'markdown', 'text' },
    root_dir = function(fname)
      return lspconfig.util.root_pattern('.cspell.yaml')(fname)
    end,
    -- cspell-lsp no provee completions, solo diagnostics; silenciar errores de completion
    on_attach = function(client)
      client.server_capabilities.completionProvider = nil
    end,
  })
end

return M
