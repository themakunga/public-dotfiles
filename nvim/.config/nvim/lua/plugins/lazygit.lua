local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/kdheepak/lazygit.nvim' },
  })

  ---@module 'lazygit'
  local ok, lazygit = pcall(require, 'lazygit')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] lazygit ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  -- local opts = {
  -- }
  --
  -- lazygit.setup(opts)

  vim.keymap.set('n', '<leader>glg', '<cmd>LazyGit<cr>', { desc = 'Open LazyGit' })
end

return M
