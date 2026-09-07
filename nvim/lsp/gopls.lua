---@type vim.lsp.Config
return {
  cmd = { 'gopls' },

  filetypes = {
    'go',
    'gomod',
    'gowork',
    'gotmpl',
  },

  root_markers = {
    'go.work',
    'go.mod',
    '.git',
  },

  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = true,
      completeFunctionCalls = true,

      analyses = {
        nilness = true,
        shadow = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },

      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}
