local M = {}

M.load = function()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('AttachedLSP-DAP', {}),
    callback = function(event)
      require('plugins.dap.keymaps').dapKeymapsAttached(event.buf)
    end,
  })
end

return M
