--- Archivo: ./lua/plugins/coding/cmp.lua
local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/folke/lazydev.nvim' },
    { src = 'https://github.com/saghen/blink.lib' },
    { src = 'https://github.com/saghen/blink.cmp' },
  })

  local ok, blink = pcall(require, 'blink.cmp')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] blink.cmp ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local opts = {
    -- ==========================================
    -- NAVEGACIÓN Y SELECCIÓN (SIN ESPACIO)
    -- ==========================================
    keymap = {
      preset = 'default',
      ['<Tab>'] = { 'select_next', 'fallback' }, -- Bajar en la lista
      ['<S-Tab>'] = { 'select_prev', 'fallback' }, -- Subir en la lista
      ['<CR>'] = { 'accept', 'fallback' }, -- Enter para aceptar
    },

    appearance = { nerd_font_variant = 'mono' },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'lazydev' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100,
        },
      },
    },
    snippets = { preset = 'default' },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  }

  blink.setup(opts)

  -- ==========================================
  -- AUTOMATIZACIÓN DE COMPILACIÓN (BUILD)
  -- ==========================================
  local lib_path = vim.fn.stdpath('data') .. '/site/pack/core/opt/blink.cmp/target/release/libblink_cmp_fuzzy.dylib'

  if vim.fn.filereadable(lib_path) == 0 then
    vim.schedule(function()
      vim.notify(
        '⚙️ Compilando el motor Rust de Blink.cmp por primera vez (esto tomará unos segundos)...',
        vim.log.levels.INFO
      )

      require('blink.cmp').build():pwait()

      vim.notify('✅ Blink.cmp compilado. ¡Autocompletado a máxima velocidad activado!', vim.log.levels.INFO)
    end)
  end
end

return M
