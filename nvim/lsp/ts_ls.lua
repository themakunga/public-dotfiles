---@type vim.lsp.Config
return {
  cmd = {
    'typescript-language-server',
    '--stdio',
  },

  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },

  root_markers = {
    {
      'pnpm-lock.yaml',
      'package-lock.json',
      'yarn.lock',
      'bun.lock',
      'bun.lockb',
    },
    {
      'tsconfig.json',
      'jsconfig.json',
      'package.json',
    },
    '.git',
  },

  settings = {
    typescript = {
      inlayHints = {
        parameterNames = {
          enabled = 'literals',
          suppressWhenArgumentMatchesName = true,
        },

        parameterTypes = {
          enabled = true,
        },

        variableTypes = {
          enabled = true,
        },

        propertyDeclarationTypes = {
          enabled = true,
        },

        functionLikeReturnTypes = {
          enabled = true,
        },

        enumMemberValues = {
          enabled = true,
        },
      },
    },
  },
}
