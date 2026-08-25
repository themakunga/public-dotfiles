--- Archivo: ./lua/plugins/editor/treesitter.lua
local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  })

  local ok, treesitter = pcall(require, 'nvim-treesitter.configs')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] nvim-treesitter.configs ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  -- Detección de archivos personalizados (Modelfile)
  vim.filetype.add({
    pattern = {
      ['config'] = 'dosini',
      ['[mM]odelfile.*'] = 'modelfile',
    },
    filename = {
      ['Modelfile'] = 'modelfile',
    },
  })

  -- Enlazar Modelfile con el parser de Dockerfile
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
    indent = { enable = true, disable = { 'ruby' } },
  }

  treesitter.setup(opts)
end

return M
