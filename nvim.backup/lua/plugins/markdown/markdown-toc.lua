local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/hedyhli/markdown-toc.nvim' },
  })

  ---@module 'markdowntoc'
  local ok, markdowntoc = pcall(require, 'Mtoc')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] markdowntoc ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local opts = {
    headings = {
      before_toc = false,
      indent_size = 2,
      pattern = '^(##+)%s+(.+)$',
    },
    auto_update = {
      enabled = true,
      -- This allows the ToC to be refreshed silently on save for any markdown file.
      -- The refresh operation uses `Mtoc update` and does NOT create the ToC if
      -- it does not exist.
      events = { 'BufWritePre' },
      pattern = '*.{md,mdown,mkd,mkdn,markdown,mdwn}',
    },
  }

  markdowntoc.setup(opts)

  vim.keymap.set('n', '<leader>mti', ':Mtoc insert<cr>', { desc = 'Markdown TOC insert on position' })
  vim.keymap.set('n', '<leader>mtu', ':Mtoc update<cr>', { desc = 'Markdown TOC update' })
  vim.keymap.set('n', '<leader>mtd', ':Mtoc insert<cr>', { desc = 'Markdown TOC remove' })
  vim.keymap.set('n', '<leader>mtt', ':Mtoc insert<cr>', { desc = 'Markdown TOC view TOC' })
end

return M
