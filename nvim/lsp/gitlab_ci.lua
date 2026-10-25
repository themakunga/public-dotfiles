---@type vim.lsp.Config
-- gitlab-ci-ls: validación y completion para archivos .gitlab-ci.yml
-- Instalado vía Nix (gitlab-ci-ls), no Mason.
return {
  cmd = { 'gitlab-ci-ls' },
  filetypes = { 'yaml' },
  root_dir = function(bufnr, cb)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if not fname:match('%.gitlab%-ci%.yml$') then
      return
    end
    local root = vim.fs.root(bufnr, { '.git' })
    if root then
      cb(root)
    end
  end,
}
