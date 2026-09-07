vim.filetype.add({
  filename = {
    Containerfile = 'dockerfile',
  },

  pattern = {
    ['Containerfile%..*'] = 'dockerfile',
    ['Dockerfile%..*'] = 'dockerfile',
  },
})

---@type vim.lsp.Config
return {
  cmd = {
    'docker-language-server',
    'start',
    '--stdio',
  },

  filetypes = {
    'dockerfile',
    'yaml.docker-compose',
  },

  root_markers = {
    {
      'compose.yaml',
      'compose.yml',
      'docker-compose.yaml',
      'docker-compose.yml',
    },
    {
      'Dockerfile',
      'Containerfile',
    },
    '.git',
  },

  get_language_id = function(_, filetype)
    if filetype == 'yaml.docker-compose' then
      return 'dockercompose'
    end

    return 'dockerfile'
  end,

  init_options = {
    telemetry = 'off',

    dockercomposeExperimental = {
      composeSupport = true,
    },
  },
}
