local M = {}

M.parsers = {
  'astro',
  'bash',
  'c',
  'css',
  'diff',
  'dockerfile',
  'editorconfig',
  'gitignore',

  -- Go
  'go',
  'gomod',
  'gosum',
  'gowork',

  -- Infrastructure
  'hcl',
  'terraform',
  'nix',

  -- Config
  'ini',
  'json',
  'jsonc',
  'nginx',
  'toml',
  'yaml',

  -- Web
  'html',
  'javascript',
  'typescript',
  'tsx',

  -- Shell
  'zsh',

  -- Others
  'latex',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'sql',
  'typst',
  'vim',
  'vimdoc',
}

M.filetypes = {
  'astro',

  -- Shell
  'bash',
  'sh',
  'zsh',

  -- C
  'c',

  -- Web
  'css',
  'html',
  'javascript',
  'typescript',
  'typescriptreact',
  'javascriptreact',

  -- Docker
  'dockerfile',
  'modelfile',

  -- Go
  'go',
  'gomod',
  'gosum',
  'gowork',

  -- Infrastructure
  'hcl',
  'terraform',
  'terraform-vars',
  'opentofu',
  'opentofu-vars',
  'nix',

  -- Configuration
  'json',
  'jsonc',
  'toml',
  'dosini',
  'nginx',

  -- YAML
  'yaml',
  'yaml.github',
  'yaml.gitlab',
  'yaml.helm-values',
  'yaml.docker-compose',

  -- Documentation
  'markdown',
  'markdown_inline',
  'latex',
  'typst',

  -- Misc
  'diff',
  'editorconfig',
  'gitignore',
  'lua',
  'python',
  'sql',
  'vim',
}

M.context = {
  mode = 'cursor',
  max_lines = 3,
}

return M
