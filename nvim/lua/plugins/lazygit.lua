local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/kdheepak/lazygit.nvim' },
  })

  KM.map({
    motion = '<leader>glg',
    cmd = '<cmd>LazyGit<CR>',
    opts = { desc = 'Open Lazygit' },
  })
end

return M
