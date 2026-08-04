local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  })

  ---@module 'nvim-treesitter.configs'
  local ok, treesitter = pcall(require, 'nvim-treesitter.configs')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] nvim-treesitter.configs ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  vim.filetype.add({
    pattern = {
      ['config'] = 'dosini', -- better syntax highlighting for config files
    },
  })

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
      'nix', -- Soporte añadido para Nix
      'python',
      'sql',
      'tsx',
      'typescript',
      'vim',
      'vimdoc',
      'yaml',
    },
    -- Install only the parsers listed above; no surprise background installs.
    auto_install = false,
    highlight = {
      enable = true,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --  If you are experiencing weird indenting issues, add the language to
      --  the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = { enable = true, disable = { 'ruby' } },
  }

  treesitter.setup(opts)
end

return M
