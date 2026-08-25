local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  })

  if not Checker.check('nvim-treesitter.configs') then
    return
  end

  vim.filetype.add({
    pattern = {
      ['config'] = 'dosini',
      ['[mM]odelfile.*'] = 'modelfile',
    },
    filename = {
      ['Modelfile'] = 'modelfile',
    },
  })

  vim.treesitter.language.register('dockerfile', 'modelfile')

  local opts = {
    ensure_installed = {
      'astro',
      'bash',
      'c',
      'css',
      'diff',
      'dockerfile',
      'editorconfig',
      'gitignore',
      'go',
      'gomod',
      'gosum',
      'gowork',
      'html',
      'javascript',
      'json',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'nix',
      'python',
      'sql',
      'tsx',
      'typescript',
      'vim',
      'vimdoc',
      'yaml',
    },
    auto_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = {
      enable = true,
      disable = { 'ruby' },
    },
  }

  require('nvim-treesitter.configs').setup(opts)

  KM.bulk_map({
    {
      motion = '<leader>Tu',
      cmd = '<cmd>TSUpdate<CR>',
      opts = { desc = 'Treesitter: Update parsers' },
    },
    {
      motion = '<leader>Ti',
      cmd = '<cmd>TSInstallInfo<CR>',
      opts = { desc = 'Treesitter: Show install info' },
    },
  })
end

return M
