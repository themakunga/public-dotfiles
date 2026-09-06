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

local mason_opts = {
  ui = {
    border = 'rounded',
    icons = {
      package_installed = '✓',
      package_pending = '➜',
      package_uninstalled = '✗',
    },
  },
}

local opts = {
  ensure_installed = ensure_installed,
}

local diagnostic_config = {
  virtual_text = false,
  update_in_insert = false,
  userline = true,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '!!!',
      [vim.diagnostic.severity.WARN] = '!!',
      [vim.diagnostic.severity.INFO] = '?',
      [vim.diagnostic.severity.HINT] = '!',
    },
  },
}

local diagnostic_vitutaltext_fn = function()
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

local lsp_autocompletion_fn = function(args)
  local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

  if client:supports_method('textDocument/completion') then
    vim.lsp.completion.enable(true, client.id, args.buf)
  end
end

local lsp_highlight_fn = function(event)
  vim.lsp.buf.clear.references()
  CMD.aucmd('lsp-highlight', {
    {
      buffer = event.buf,
    },
  })
end

local lsp_navigation_fn = function(event)
  local fzf = require('fzf-lua')
  local fnopts = {
    jump1 = true,
    ignore_current_line = true,
  }

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
    CMD.aucmd('lsp-hightlight', {
      {
        event = { 'CursorHold', 'CursorHoldI' },
        buffer = event.buf,
        callback = vim.lsp.buf.document_highlight,
      },
      {
        event = { 'CursorHold', 'CursorHoldI' },
        buffer = event.buf,
        callback = vim.lsp.buf.clear_references,
      },
    })

    CMD.aucmd('lsp-detach', {
      {
        event = 'LspDetach',
        callback = lsp_highlight_fn,
      },
    })
  end

  if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
    KM.map({
      {
        motion = '<leader>th',
        cmd = function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
        end,
        opts = { desc = 'Toggle inlay hints' },
      },
    })
  end
end

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/mason-org/mason.nvim' },
    { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
    { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
  })

  if not Checker.check({ 'mason', 'mason-lspconfig', 'mason-tool-installer' }) then
    return
  end

  require('mason').setup(mason_opts)
  require('mason-lspconfig').setup()
  require('mason-tool-installer').setup(opts)

  vim.diagnostic.config(diagnostic_config)

  CMD.aucmd('cursor-diagnostic', {
    {
      event = { 'CursorMoved', 'CursorMovedI', 'DiagnosticChanged' },
      desc = 'Diagnostic in line show in cursor',
      callback = diagnostic_vitutaltext_fn,
    },
  })
  CMD.aucmd('lsp-autocompletion', {
    {
      event = 'LspAttach',
      callback = lsp_autocompletion_fn,
    },
  })

  CMD.aucmd('lsp-navigation', {
    {
      event = 'LspAttach',
      callback = lsp_navigation_fn,
    },
  })
end

return M
