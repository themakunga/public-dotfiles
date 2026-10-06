---@type vim.lsp.Config
return {
  cmd = { 'markdown-oxide' },

  filetypes = { 'markdown' },

  root_markers = {
    '.obsidian',
    'README.md',
    '.git',
  },

  workspace_required = false,
}
