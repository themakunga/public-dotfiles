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
    -- Lua LSP for editing this config: completion, annotations, signatures.
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
    -- Install the binaries the servers + formatters need.
    mti.setup({
      ensure_installed = {
        -- language servers
        'lua-language-server',
        'vtsls',
        'eslint-lsp',
        'tailwindcss-language-server',
        'css-lsp',
        -- gopls is provided by mise (go: backend) so it lands on PATH as a
        -- shim; mason can't install it because mise overrides GOBIN.
        'pyright',
        'ruff',
        'astro-language-server',
        'dockerfile-language-server',
        'docker-compose-language-service',
        'neocmakelsp',
        'nil', -- Nix language server

        -- formatters
        'stylua',
        'prettier',
        'prettierd',
        'biome',
        'alejandra', -- Nix flake formatter
      },
    })
  end

  ---@module 'lspconfig'
  local ok_lspconfig, lspconfig = pcall(require, 'lspconfig')
  if not ok_lspconfig then
    vim.notify('[CHECK REQUIRE FAILED] lspconfig ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  -- Servers to activate. Servers without a file in `lsp/` use
  -- nvim-lspconfig's bundled defaults as-is.
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
    'nil_ls', -- Activa el LSP para Nix
  }

  -- Broadcast completion capabilities (blink.cmp) + ufo folding to every
  -- server via the wildcard config, so individual `lsp/*.lua` files don't
  -- have to repeat it.
  local ok_blink, blink = pcall(require, 'blink.cmp')
  local capabilities = ok_blink and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

  capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }

  vim.lsp.config('*', { capabilities = capabilities })

  vim.lsp.enable(servers)

  -- Buffer-local keymaps + behavior when a server attaches. Neovim 0.11
  -- already provides defaults (K hover, grn rename, gra code action,
  -- grr refs, gri impl, gO symbols, C-s signature, [d/]d diagnostics);
  -- we only add definition/type navigation via fzf-lua and a few extras.
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

      -- Highlight references of the word under the cursor. Gated on
      -- CursorHold (debounced by `updatetime`), so it is cheap.
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

      -- Inlay hints are off by default; this toggles them per-buffer.
      if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
        map('<leader>th', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
        end, 'Toggle Inlay Hints')
      end
    end,
  })
end

return M
