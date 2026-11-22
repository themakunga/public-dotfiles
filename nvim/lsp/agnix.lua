---@type vim.lsp.Config
return {
  cmd = { 'agnix-lsp' },
  filetypes = { 'markdown', 'json', 'jsonc', 'toml', 'yaml' },
  root_dir = function(bufnr, on_dir)
    local path = vim.api.nvim_buf_get_name(bufnr)
    local name = vim.fs.basename(path)
    local supported = vim.tbl_contains({
      'SKILL.md',
      'AGENTS.md',
      'AGENTS.local.md',
      'AGENTS.override.md',
      'CLAUDE.md',
      'CLAUDE.local.md',
      'GEMINI.md',
      'plugin.json',
      'mcp.json',
      '.mcp.json',
      '.cursorrules',
      'copilot-instructions.md',
      '.agnix.toml',
    }, name) or name:match('%.mcp%.json$') or path:match('/agents/[^/]+%.md$') or path:match(
      '/%.claude/agents/.*%.md$'
    ) or path:match('/%.claude/settings[^/]*%.json$') or path:match('/%.cursor/rules/.*%.mdc$') or path:match(
      '/%.github/instructions/.*%.instructions%.md$'
    )
    if supported then
      on_dir(vim.fs.root(bufnr, { '.agnix.toml', '.git' }) or vim.fs.dirname(path))
    end
  end,
}
