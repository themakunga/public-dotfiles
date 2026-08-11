--- Archivo: ./lua/plugins/editor/lspconfig.lua
local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/folke/lazydev.nvim' },
    { src = 'https://github.com/williamboman/mason.nvim' },
    { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
  })

  ---@module 'lazydev'
  local ok_lazydev, lazydev = pcall(require, 'lazydev')
  if not ok_lazydev then
    vim.notify('[CHECK REQUIRE FAILED] lazydev ' .. debug.getinfo(2).source, vim.log.levels.WARN)
  else
    lazydev.setup({
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    })
  end

  ---@module 'mason'
  local ok_mason, mason = pcall(require, 'mason')
  if not ok_mason then
    vim.notify('[CHECK REQUIRE FAILED] mason ' .. debug.getinfo(2).source, vim.log.levels.WARN)
  else
    mason.setup({})
  end

  ---@module 'mason-tool-installer'
  local ok_mti, mti = pcall(require, 'mason-tool-installer')
  if not ok_mti then
    vim.notify('[CHECK REQUIRE FAILED] mason-tool-installer ' .. debug.getinfo(2).source, vim.log.levels.WARN)
  else
    mti.setup({
      ensure_installed = {
        'lua-language-server',
        'vtsls',
        'eslint-lsp',
        'tailwindcss-language-server',
        'css-lsp',
        'pyright',
        'ruff',
        'astro-language-server',
        'dockerfile-language-server',
        'docker-compose-language-service',
        'neocmakelsp',
        'nil',
        'stylua',
        'prettier',
        'prettierd',
        'biome',
        'alejandra',
      },
    })
  end

  ---@module 'lspconfig'
  local ok_lspconfig, lspconfig = pcall(require, 'lspconfig')
  if not ok_lspconfig then
    vim.notify('[CHECK REQUIRE FAILED] lspconfig ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  -- ==========================================
  -- CONFIGURACIÓN GLOBAL DE DIAGNÓSTICOS
  -- ==========================================
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

  -- ==========================================
  -- VIRTUAL TEXT SOLO EN LA LÍNEA ACTUAL
  -- ==========================================
  local cursor_diag_group = vim.api.nvim_create_augroup('CursorDiagnostics', { clear = true })
  local cursor_diag_ns = vim.api.nvim_create_namespace('CursorVirtualText')

  local function show_cursor_diagnostics()
    local bufnr = vim.api.nvim_get_current_buf()

    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = cursor[1] - 1

    -- SOLUCIÓN: Usar la API oficial de diagnósticos para ocultarlos
    vim.diagnostic.hide(cursor_diag_ns, bufnr)

    local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })

    if #diagnostics > 0 then
      -- Dibuja el virtual text solo si hay errores en esta línea exacta
      vim.diagnostic.show(cursor_diag_ns, bufnr, diagnostics, {
        virtual_text = {
          prefix = '●',
          source = 'if_many',
        },
        signs = false,
        underline = false,
      })
    end
  end

  -- Se ejecuta cada vez que mueves el cursor o un servidor LSP manda un diagnóstico nuevo
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'DiagnosticChanged' }, {
    group = cursor_diag_group,
    callback = show_cursor_diagnostics,
  })

  -- Servers to activate.
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

  local ok_blink, blink = pcall(require, 'blink.cmp')
  local capabilities = ok_blink and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

  capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }

  vim.lsp.config('*', { capabilities = capabilities })
  vim.lsp.enable(servers)

  -- Buffer-local keymaps + behavior when a server attaches.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
      local map = function(keys, func, desc, mode)
        vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      map('gd', function()
        require('fzf-lua').lsp_definitions({ jump1 = true, ignore_current_line = true })
      end, 'Goto Definition')

      map('gy', function()
        require('fzf-lua').lsp_typedefs({ jump1 = true, ignore_current_line = true })
      end, 'Goto Type Definition')

      map('grr', function()
        require('fzf-lua').lsp_references({ jump1 = true, ignore_current_line = true })
      end, 'References')

      map('gri', function()
        require('fzf-lua').lsp_implementations({ jump1 = true, ignore_current_line = true })
      end, 'Goto Implementation')

      map('<leader>ca', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })

      local client = vim.lsp.get_client_by_id(event.data.client_id)

      if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
        local hl = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = hl,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = hl,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({
              group = 'lsp-highlight',
              buffer = event2.buf,
            })
          end,
        })
      end

      if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
        map('<leader>th', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
        end, 'Toggle Inlay Hints')
      end
    end,
  })
end

return M
