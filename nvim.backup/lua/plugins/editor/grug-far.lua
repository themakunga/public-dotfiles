local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/MagicDuck/grug-far.nvim' },
  })

  ---@module 'grug-far'
  local ok, grug_far = pcall(require, 'grug-far')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] grug-far ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local opts = {
    headerMaxWidth = 80,
  }

  grug_far.setup(opts)

  vim.keymap.set({ 'n', 'v' }, '<leader>sr', function()
    local grug = require('grug-far')
    local ext = vim.bo.buftype == '' and vim.fn.expand('%:e')
    grug.open({
      transient = true,
      prefills = {
        filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
      },
    })
  end, { desc = 'Replace' })
end

return M
