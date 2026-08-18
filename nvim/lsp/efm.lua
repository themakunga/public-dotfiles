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
      swift = {
        {
          lintCommand = 'swiftlint lint --quiet --use-script-input-files',
          lintStdin = true,
          lintFormats = { 
            '%f:%l:%c: %trror: %m', 
            '%f:%l:%c: %tarning: %m',
            '%f:%l: %trror: %m',
            '%f:%l: %tarning: %m'
          },
        }
    },
  },
}
