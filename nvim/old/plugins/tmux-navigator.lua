local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/christoomey/vim-tmux-navigator' },
  })
end

return M
