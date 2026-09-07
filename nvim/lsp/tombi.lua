---@type vim.lsp.Config
return {
  cmd = {
    'tombi',
    'lsp',
  },

  filetypes = {
    'toml',
  },

  root_markers = {
    'tombi.toml',
    '.tombi.toml',

    'Cargo.toml',
    'pyproject.toml',

    '.git',
  },

  workspace_required = false,
}
