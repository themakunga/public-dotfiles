local M = {}

local treesitter_opts = {
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

local treesitter_context_opts = {
  mode = 'cursor',
  max_lines = 3,
}

local function treesitter_add_modelfiles()
  vim.filetype.add({
    pattern = {
      ['config'] = 'dosing',
      ['[nM]odelfile.*'] = 'modelfile',
    },
    filename = {
      ['Modelfile'] = 'modelfile',
    },
  })

  vim.treesitter.language.register('dockerfile', 'modelfile')
end

local function toggle_treesitter_context(tsc)
  if tsc.enabled then
    tsc.disable()
  else
    tsc.enable()
  end
end

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },
  })

  if not Checker.check({ 'nvim-treesitter.configs', 'treesitter-context' }) then
    return
  end

  require('nvim-treesitter.configs').setup(treesitter_opts)
  require('treesitter-context').setup(treesitter_context_opts)

  treesitter_add_modelfiles()

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
    {
      motion = '<leader>ut',
      cmd = function()
        toggle_treesitter_context(require('treesitter-context'))
      end,
      opts = { desc = 'Toggle Treesitter Context' },
    },
  })
end

return M
