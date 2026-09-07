---@type vim.lsp.Config
return {
  cmd = {
    'vscode-json-language-server',
    '--stdio',
  },

  filetypes = {
    'json',
    'jsonc',
  },

  root_markers = {
    'package.json',
    '.git',
  },

  workspace_required = false,

  init_options = {
    provideFormatter = true,
  },

  settings = {
    json = {
      validate = {
        enable = true,
      },
    },
  },
}
