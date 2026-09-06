local M = {}

local ensure_installed = {
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
}

local servers = {
  'lua_ls',
  'eslint',
  'vtsls',
  'tailwindcss',
  'cssls',
  'gopls',
  'pyright',
  'ruff',
  'astro',
  'dockerls',
  'docker_compose_language_service',
  'neocmake',
  'nil_ls',
}

local function show_cursor_diagnostics()
  local ns = vim.api.nvim_create_namespace('CursorVirtualText')
  local bufnr = vim.api.nvim_get_current_buf()

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1

  vim.diagnostic.hide(ns, bufnr)

  local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })

  if #diagnostics > 0 then
    vim.diagnostic.show(ns, bufnr, diagnostics, {
      virtual_text = {
        prefix = '●',
        source = 'if_many',
      },
      signs = false,
      underline = false,
    })
  end
end

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/folke/lazydev.nvim' },
    { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
    { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
    { src = 'https://github.com/mason-org/mason.nvim' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/L3MON4D3/LuaSnip' },
    { src = 'https://github.com/rafamadriz/friendly-snippets' },
    { src = 'https://github.com/Saghen/blink.lib' },
    { src = 'https://github.com/Saghen/blink.cmp', version = vim.version.range('^1') },
  })

  if not Checker.check('lazydev') then
    return
  else
    require('lazydev').setup({
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    })
  end

  if
    not Checker.check({
      'mason',
      'mason-lspconfig',
      'mason-tool-installer',
      'luasnip',
      'blink.lib',
      'blink.cmp',
    })
  then
    return
  end

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
    ensure_installed = ensure_installed,
  }

  local cmp_opta = {
    signature = { enabled = true },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 500 },
      menu = {
        auto_show = true,
        draw = {
          treesitter = { 'lsp' },
          columns = { { 'kind_icon', 'label', 'label_description', gap = 1 }, { 'kind' } },
        },
      },
    },
  }

  require('mason').setup(mason_opts)
  require('mason-lspconfig').setup(mason_lspconfig_opts)
  require('mason-tool-installer').setup(mason_tool_installer_opts)

  require('luasnip.loaders.from_vscode').lazy_load()
  require('blink.cmp').setup(cmp_opta)

  vim.diagnostic.config({
    virtual_text = false, -- Apagado globalmente
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      border = 'rounded',
      source = 'always',
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = '■',
        [vim.diagnostic.severity.WARN] = '■',
        [vim.diagnostic.severity.INFO] = '■',
        [vim.diagnostic.severity.HINT] = '■',
      },
    },
  })

  CMD.aucmd('CursorDiagnostics', {
    {
      event = { 'CursorMoved', 'CursorMovedI', 'DiagnosticChanged' },
      desc = 'Cursor Diagnostic inline',
      callback = show_cursor_diagnostics,
    },
  })

  local capabilities = require('blink.cmp').get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

  capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }

  vim.lsp.config('*', { capabilities = capabilities })
  vim.lsp.enable(servers)

  CMD.aucmd('LSPNavigation', {
    {
      event = 'LspAttach',
      callback = function(event)
        local fzf = require('fzf-lua')
        local fnopts = { jump1 = true, ignore_current_line = true }

        KM.bulk_map({
          {
            motion = 'gd',
            cmd = function()
              fzf.lsp_definitions(fnopts)
            end,
            opts = { desc = 'Goto definition' },
          },
          {
            motion = 'gy',
            cmd = function()
              fzf.lsp_typedefs(fnopts)
            end,
            opts = { desc = 'Goto Type Definition' },
          },
          {
            motion = 'grr',
            cmd = function()
              fzf.lsp_references(fnopts)
            end,
            opts = { desc = 'References' },
          },
          {
            motion = 'gri',
            cmd = function()
              fzf.lsp_implementations(fnopts)
            end,
            opts = { desc = 'Goto Implementation' },
          },
          {
            mode = { 'n', 'x' },
            motion = '<leader>ca',
            cmd = vim.lsp.buf.code_action,
            opts = { desc = 'Code Action' },
          },
        })

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          CMD.aucmd('lsp-highlight', {
            {
              event = { 'CursorHold', 'CursorHoldI' },
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            },
            {
              event = { 'CursorMoved', 'CursorMovedI' },
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            },
          })

          CMD.aucmd('lsp-detach', {
            {
              event = 'LspDetach',
              callback = function(ev)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({
                  group = 'lsp-highlight',
                  buffer = ev.buf,
                })
              end,
            },
          })
        end

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          KM.map({
            motion = '<leader>th',
            cmd = function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end,
            opts = { desc = 'Toggle Inlay Hints' },
          })
        end
      end,
    },
  })
end

return M
