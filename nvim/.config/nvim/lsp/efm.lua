---@type vim.lsp.Config
return {
  cmd = { 'efm-langserver' },
  rootMarkers = { '.git', 'nginx.conf', 'conf.d' },
  filetypes = { 'nginx' },
  init_options = { documentFormatting = true },
  settings = {
    languages = {
      nginx = {
        {
          formatCommand = 'nginx-config-formatter --in-place ${INPUT}',
          formatStdin = false,
        },
      },
    },
  },
}
