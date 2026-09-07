local M = {}

local treesitter_parsers = {
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
  'toml',
  'yaml',
  'nginx',

  -- Web / TypeScript
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

local treesitter_context_opts = {
  mode = 'cursor',
  max_lines = 3,
}

local function setup_filetypes()
  vim.filetype.add({
    extension = {
      ini = 'dosini',
      cfg = 'dosini',
    },

    filename = {
      ['Modelfile'] = 'modelfile',
      ['modelfile'] = 'modelfile',

      ['Containerfile'] = 'dockerfile',
      ['containerfile'] = 'dockerfile',
    },

    pattern = {
      -- Ollama Modelfile variants
      ['.*[Mm]odelfile%..*'] = 'modelfile',

      -- Containerfile variants
      ['.*[Cc]ontainerfile%..*'] = 'dockerfile',

      -- Nginx
      ['.*/nginx/.*%.conf'] = 'nginx',
      ['.*/nginx/conf%.d/.*%.conf'] = 'nginx',
      ['.*/nginx/sites%-available/.*'] = 'nginx',
      ['.*/nginx/sites%-enabled/.*'] = 'nginx',
    },
  })

  -- Modelfile uses Dockerfile syntax
  vim.treesitter.language.register('dockerfile', 'modelfile')

  -- Neovim uses "dosini" as filetype, while Treesitter uses "ini"
  vim.treesitter.language.register('ini', 'dosini')

  -- OpenTofu uses Terraform/HCL syntax
  vim.treesitter.language.register('terraform', {
    'opentofu',
    'opentofu-vars',
  })

  -- Specialized YAML filetypes
  vim.treesitter.language.register('yaml', {
    'yaml.docker-compose',
    'yaml.gitlab',
    'yaml.github',
    'yaml.helm-values',
  })
end

local function setup_treesitter()
  local treesitter = require('nvim-treesitter')

  -- Equivalent to the old ensure_installed.
  -- Already installed parsers are ignored.
  treesitter.install(treesitter_parsers)

  local group = vim.api.nvim_create_augroup('TreesitterConfig', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = '*',

    callback = function(event)
      local bufnr = event.buf

      -- Start highlighting only when a parser exists.
      local ok = pcall(vim.treesitter.start, bufnr)

      if not ok then
        return
      end

      local filetype = vim.bo[bufnr].filetype

      local language = vim.treesitter.language.get_lang(filetype)

      if not language then
        return
      end

      -- Only enable Treesitter indentation when the
      -- language actually provides an indents query.
      local query_ok, query = pcall(vim.treesitter.query.get, language, 'indents')

      if query_ok and query then
        vim.bo[bufnr].indentexpr = 'v:lua.require\'nvim-treesitter\'.indentexpr()'
      end
    end,
  })
end

M.plugin = function()
  vim.pack.add({
    {
      src = 'https://github.com/neovim-treesitter/treesitter-parser-registry',
    },
    {
      src = 'https://github.com/neovim-treesitter/nvim-treesitter',
    },
    {
      src = 'https://github.com/nvim-treesitter/nvim-treesitter-context',
    },
  })

  if not Checker.check({
    'nvim-treesitter',
    'treesitter-context',
  }) then
    return
  end

  setup_filetypes()
  setup_treesitter()

  require('treesitter-context').setup(treesitter_context_opts)

  KM.bulk_map({
    {
      motion = '<leader>Tu',
      cmd = '<cmd>TSUpdate<CR>',
      opts = {
        desc = 'Treesitter: Update parsers',
      },
    },

    {
      motion = '<leader>Ti',
      cmd = '<cmd>TSStatus<CR>',
      opts = {
        desc = 'Treesitter: Show parser status',
      },
    },

    {
      motion = '<leader>ut',
      cmd = '<cmd>TSContext toggle<CR>',
      opts = {
        desc = 'Toggle Treesitter Context',
      },
    },
  })
end

return M
