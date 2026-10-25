---@type vim.lsp.Config
-- efm-langserver: conecta actionlint como linter para GitHub Actions workflows.
-- Se activa solo en archivos bajo .github/workflows/.
return {
  cmd = { 'efm-langserver' },
  filetypes = { 'yaml' },
  root_dir = function(bufnr, cb)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if not fname:match('%.github[/\\]workflows[/\\]') then
      return
    end
    local root = vim.fs.root(bufnr, { '.github', '.git' })
    if root then
      cb(root)
    end
  end,
  init_options = {
    rootMarkers = { '.git/' },
    languages = {
      yaml = {
        {
          lintCommand = 'actionlint -stdin-filename ${INPUT} -',
          lintStdin = true,
          lintFormats = { '%f:%l:%c: %m' },
          lintSeverity = 1,
        },
      },
    },
  },
}
