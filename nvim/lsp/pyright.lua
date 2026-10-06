---@type vim.lsp.Config
return {
  cmd = { 'pyright-langserver', '--stdio' },

  filetypes = { 'python' },

  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    '.python-version',
    'pyrightconfig.json',
    '.git',
  },

  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'openFilesOnly',
      },
    },
  },
}
