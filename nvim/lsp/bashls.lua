---@type vim.lsp.Config
return {
  cmd = {
    'bash-language-server',
    'start',
  },

  filetypes = {
    'bash',
    'sh',
  },

  root_markers = {
    '.git',
  },

  workspace_required = false,

  settings = {
    bashIde = {
      globPattern = '*@(.sh|.inc|.bash|.command)',

      backgroundAnalysisMaxFiles = 500,

      shellcheckPath = 'shellcheck',

      shfmt = {
        path = 'shfmt',
        languageDialect = 'auto',
        simplifyCode = true,
      },
    },
  },
}
