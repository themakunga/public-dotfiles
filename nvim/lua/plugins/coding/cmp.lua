local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/folke/lazydev.nvim' },
    { src = 'https://github.com/saghen/blink.cmp' },
  })

  ---@module 'blink.cmp'
  local ok, blink = pcall(require, 'blink.cmp')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] blink.cmp ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  ---@type blink.cmp.Config
  local opts = {
    -- Default preset: <C-y> accept, <C-n>/<C-p> select, <C-space> open/docs,
    -- <C-e> hide, <C-b>/<C-f> scroll docs, <Tab>/<S-Tab> snippet jump.
    keymap = { preset = 'default' },
    appearance = { nerd_font_variant = 'mono' },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'lazydev' },
      providers = {
        -- lazydev completions for editing this Neovim config; high score so
        -- they outrank (and dedupe) lua_ls's own suggestions.
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100,
        },
      },
    },
    -- Use blink's built-in snippet engine (no LuaSnip).
    snippets = { preset = 'default' },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  }

  blink.setup(opts)
end

return M
