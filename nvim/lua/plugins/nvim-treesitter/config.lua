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
  'hyprlang',
  'ini',
  'json',
  'nginx',
  'tmux',
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
  'java',
  'latex',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'sql',
  'todotxt',
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
  'hyprlang',
  'json',
  'jsonc',
  'toml',
  'dosini',
  'nginx',
  'tmux',

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
  'java',
  'diff',
  'editorconfig',
  'gitignore',
  'lua',
  'python',
  'sql',
  'todotxt',
  'vim',
}

M.context = {
  mode = 'cursor',
  max_lines = 3,
}

return M
