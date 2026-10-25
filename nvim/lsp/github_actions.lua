---@type vim.lsp.Config
-- GitHub Actions Language Server: detecta versiones desactualizadas de actions,
-- provee completion de action inputs/outputs y validación de sintaxis del workflow.
-- Se activa solo en archivos bajo .github/workflows/.
return {
  cmd = { vim.fn.expand('~/.local/share/nvim-lsp/gh-actions-ls/node_modules/.bin/gh-actions-language-server'), '--stdio' },
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
  -- sessionToken: leído de gh CLI para no hardcodear el token.
  init_options = {
    sessionToken = vim.fn.system('gh auth token 2>/dev/null'):gsub('%s+$', ''),
  },
  settings = {
    ['github-actions'] = {
      workflows = { enabled = true },
    },
  },
}
