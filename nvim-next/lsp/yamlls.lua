---@type vim.lsp.Config
return {
  cmd = { 'yaml-language-server', '--stdio' },

  filetypes = {
    'yaml',
    'yaml.gitlab',
    'yaml.github',
    'yaml.helm-values',
  },

  root_markers = {
    'Chart.yaml',
    'kustomization.yaml',
    'kustomization.yml',
    'skaffold.yaml',
    'skaffold.yml',
    '.github',
    '.git',
  },

  settings = {
    redhat = {
      telemetry = {
        enabled = false,
      },
    },

    yaml = {
      format = {
        enable = true,
      },

      validate = true,
      hover = true,
      completion = true,
      keyOrdering = false,

      schemaStore = {
        enable = true,
      },

      kubernetesCRDStore = {
        enable = true,
      },

      schemas = {
        -- GitHub Actions workflows
        ['https://json.schemastore.org/github-workflow.json'] = {
          '/.github/workflows/*.yml',
          '/.github/workflows/*.yaml',
          '.github/workflows/*.yml',
          '.github/workflows/*.yaml',
        },

        -- GitHub custom/composite actions
        ['https://json.schemastore.org/github-action.json'] = {
          '/action.yml',
          '/action.yaml',
          '**/action.yml',
          '**/action.yaml',
        },

        -- Kubernetes
        kubernetes = {
          '**/k8s/**/*.yaml',
          '**/k8s/**/*.yml',

          '**/kubernetes/**/*.yaml',
          '**/kubernetes/**/*.yml',

          '**/manifests/**/*.yaml',
          '**/manifests/**/*.yml',

          '**/deploy/**/*.yaml',
          '**/deploy/**/*.yml',

          '**/argo/**/*.yaml',
          '**/argo/**/*.yml',

          '**/workflows/**/*.yaml',
          '**/workflows/**/*.yml',

          '**/kustomization.yaml',
          '**/kustomization.yml',
        },
      },
    },
  },

  on_init = function(client)
    client.server_capabilities.documentFormattingProvider = true
  end,
}
