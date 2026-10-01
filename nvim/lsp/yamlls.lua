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
