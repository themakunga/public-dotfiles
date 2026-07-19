local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/folke/which-key.nvim' },
  })

  local ok, whichkey = pcall(require, 'which-key')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] wichkey ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end
  local opts = {
    delay = 0,
    defaults = {
      ['<leader>b'] = { name = '+Buffer' },
    },
  }

  whichkey.setup(opts)

  vim.keymap.set('n', '<leader>?', function()
    whichkey.show({ global = true })
  end, { desc = 'Buffer local keymaps' })
end

return M
