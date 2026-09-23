---@type vim.lsp.Config
return {
  -- TypeScript 7 (Go rewrite) — requires `tsc` (typescript_7) on PATH.
  -- Auto-discovers from node_modules/.bin/tsc or system PATH.
  cmd = { 'tsc', '--lsp', '--stdio' },

  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },

  root_markers = {
    {
      'pnpm-lock.yaml',
      'package-lock.json',
      'yarn.lock',
      'bun.lock',
      'bun.lockb',
    },
    {
      'tsconfig.json',
      'jsconfig.json',
      'package.json',
    },
    '.git',
  },
}
