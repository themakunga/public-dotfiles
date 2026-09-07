local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/sQVe/sort.nvim' },
  })

  if not Checker.check('sort') then
    return
  end

  require('sort').setup({})

  KM.bulk_map({
    { mode = { 'n', 'v', 'x' }, motion = 'go', cmd = '<cmd>Sort<CR>', opts = { desc = 'Sort' } },
    { mode = { 'n', 'v', 'x' }, motion = 'gi', cmd = '<cmd>Sort inverse<CR>', opts = { desc = 'Sort inverse' } },
    {
      mode = { 'n', 'v', 'x' },
      motion = 'gO',
      cmd = '<cmd>Sort ignore-case<CR>',
      opts = { desc = 'Sort ignore case' },
    },
    {
      mode = { 'n', 'v', 'x' },
      motion = 'gI',
      cmd = '<cmd>Sort inverse ignore-case<CR>',
      opts = { desc = 'Sort inverse ignore case' },
    },
  })
end

return M
