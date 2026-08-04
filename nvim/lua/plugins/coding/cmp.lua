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

  -- Comando para compilar/descargar el motor de Rust manualmente
  vim.api.nvim_create_user_command('BlinkBuild', function()
    vim.notify('Descargando/Construyendo binario de Blink.cmp...', vim.log.levels.INFO)
    require('blink.cmp').build():pwait()
    vim.notify('¡Blink.cmp compilado con éxito! Reinicia Neovim.', vim.log.levels.INFO)
  end, { desc = 'Build blink.cmp native Rust fuzzy matcher' })

  local opts = {
    keymap = { preset = 'default' },
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
end

return M
