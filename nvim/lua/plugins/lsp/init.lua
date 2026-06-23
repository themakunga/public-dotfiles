local M = {}

M.ensure_installed = {

  'alejandra',
  'ansiblels',
  'bash-debug-adapter',
  'bashls',
  'cssls',
  'debugpy',
  'delve',
  'diagnosticls',
  'docker_compose_language_service',
  'dockerls',
  'dotls',
  'editorconfig-checker',
  'efm',
  'emmet_ls',
  'eslint',
  'eslint',
  'firefox-debug-adapter',
  'glint',
  'go-debug-adapter',
  'gopls',
  'graphql',
  'groovyls',
  'html',
  'jdtls',
  'jqls',
  'js-debug-adapter',
  'local-lua-debugger-vscode',
  'lua_ls',
  'markdown_oxide',
  'nginx-config-formatter',
  'nginx-language-server',
  'prismals',
  'puppet',
  'puppet-editor-services',
  'pylsp',
  'rust_analyzer',
  'snyk_ls',
  'somesass_ls',
  'sqlls',
  'stylua',
  'tailwindcss',
  'taplo',
  'tflint',
  'tofu_ls',
  'tombi',
  'ts_ls',
  'yamlls',
  -- 'nixfmt', -- this is included in the nix file so its not necessary, this message works as remember
}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
    { src = 'https://github.com/jay-babu/mason-nvim-dap.nvim' },
    { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
    { src = 'https://github.com/mason-org/mason.nvim' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/nvim-neotest/nvim-nio' },
    { src = 'https://github.com/JoosepAlviste/nvim-ts-context-commentstring' },
  })

  local to_check = {
    'mason',
    'mason-lspconfig',
    'mason-tool-installer',
    'mason-nvim-dap',
    'ts_context_commentstring',
  }

  local check = require('utils.check-requires').check(to_check)

  if not check then
    return
  end

  local mason = require('mason')
  local mason_lspconfig = require('mason-lspconfig')
  local mason_tool_installer = require('mason-tool-installer')

  local ui_opts = {
    border = 'rounded',
    icons = {
      package_installed = '✓',
      package_pending = '➜',
      package_uninstalled = '✗',
    },
  }

  local mason_opts = {
    ui = ui_opts,
    log_level = vim.log.levels.DEBUG,
    max_concurrent_installers = 6,
  }

  local mason_lspconfig_opts = {}

  local mason_tool_installer_opts = {
    ensure_installed = M.ensure_installed,
  }

  mason.setup(mason_opts)
  mason_lspconfig.setup(mason_lspconfig_opts)
  mason_tool_installer.setup(mason_tool_installer_opts)

  -- Diagnostics configuration
  vim.diagnostic.config({
    virtual_text = {
      source = 'if_many',
      current_line = true,
    },
    underline = true,
    signs = true,
    update_in_insert = false,
    severity_sort = true,
  })

  local ts_context_commentstring = require('ts_context_commentstring')

  local ts_context_commentstring_ops = {
    enable_autocmd = false,
  }

  ts_context_commentstring.setup(ts_context_commentstring_ops)

  require('plugins.lsp.keymaps').global()
  require('plugins.lsp.autocmd').load()
end

return M
