---@type vim.lsp.Config
-- GitHub Actions Language Server: detecta versiones desactualizadas de actions,
-- provee completion de action inputs/outputs y validación de sintaxis del workflow.
-- Se activa solo en archivos bajo .github/workflows/.
return {
  cmd = { 'github-actions-language-server', '--stdio' },
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
  settings = {
    ['github-actions'] = {
      workflows = {
        enabled = true,
      },
    },
  },
}
