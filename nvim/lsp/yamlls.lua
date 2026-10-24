---@type vim.lsp.Config
return {
  settings = {
    yaml = {
      validate = true,
      completion = true,
      hover = true,
      schemaStore = { enable = true },
      kubernetesCRDStore = { enable = true },
      schemas = {
        -- GitHub Actions: validación + completion de action names y keys
        ['https://json.schemastore.org/github-workflow.json'] = '.github/workflows/**',
        ['https://json.schemastore.org/github-action.json'] = {
          '.github/actions/**',
          'action.yml',
          'action.yaml',
        },
        kubernetes = {
          '**/argo/**/*.{yaml,yml}',
          '**/argocd/**/*.{yaml,yml}',
          '**/argo-workflows/**/*.{yaml,yml}',
          '**/kubernetes/**/*.{yaml,yml}',
          '**/k8s/**/*.{yaml,yml}',
          '**/manifests/**/*.{yaml,yml}',
        },
      },
    },
  },
}
