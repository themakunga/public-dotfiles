local M = {}

M.ensure_installed = {
  'bash',
  'git_config',
  'git_rebase',
  'gitattributes',
  'gitcommit',
  'gitignore',
  'go',
  'graphql',
  'groovy',
  'hcl',
  'helm',
  'html',
  'http',
  'ini',
  'java',
  'javadoc',
  'javascript',
  'jinja',
  'jinja_inline',
  'jq',
  'jsdoc',
  'json',
  'json',
  'json5',
  'kotlin',
  'koto',
  'latex',
  'liquid',
  'llvm',
  'lua',
  'luadoc',
  'make',
  'markdown',
  'markdown_inline',
  'mermaid',
  'nginx',
  'ninja',
  'nix',
  'objc',
  'ocaml',
  'ocaml_interface',
  'pascal',
  'pem',
  'python',
  'terraform',
  'yaml',
}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  })
  local ok, nvim_treesitter = pcall(require, 'nvim-treesitter.configs')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] nvim-treesitter ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local opts = {
    ensure_installed = M.ensure_installed,
    auto_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_hightlighting = false,
    },
    indent = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<C-space>',
        node_incremental = '<C-space>',
        scope_incremental = false,
        node_decremental = '<bs>',
      },
    },
  }

  nvim_treesitter.setup(opts)

  vim.api.nvim_create_autocmd('PackChanged', {
    desc = 'Handle nvim-treesitter updates',
    group = vim.api.nvim_create_augroup('nvim-treesitter-pack-changed-update-handler', { clear = true }),
    callback = function(ev)
      if ev.data.kind == 'update' then
        vim.notify('nvim-treesitter updated, running TSUpdate...', vim.log.levels.INFO)
        ---@diagnostic disable-next-line: param-type-mismatch, redefined-local
        local ok = pcall(vim.cmd, 'TSUpdate')
        if ok then
          vim.notify('TSUpdate completed successfully!', vim.log.levels.INFO)
        else
          vim.notify('TSUpdate command not available yet, skipping', vim.log.levels.WARN)
        end
      end
    end,
  })
end

return M
