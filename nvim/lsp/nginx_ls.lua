vim.filetype.add({
  filename = {
    ['nginx.conf'] = 'nginx',
  },

  pattern = {
    ['.*/nginx/.*%.conf'] = 'nginx',
    ['.*/nginx/conf%.d/.*%.conf'] = 'nginx',
    ['.*/nginx/sites%-available/.*'] = 'nginx',
    ['.*/nginx/sites%-enabled/.*'] = 'nginx',
  },
})

---@type vim.lsp.Config
return {
  cmd = {
    'nginx-language-server',
  },

  filetypes = {
    'nginx',
  },

  root_markers = {
    'nginx.conf',
    '.git',
  },

  workspace_required = false,
}
