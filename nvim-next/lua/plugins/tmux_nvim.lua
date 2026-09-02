local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/aserowy/tmux.nvim' },
  })

  if not Checker.check('tmux') then
    return
  end

  require('tmux').setup({
    navigation = {
      enable_default_keybindings = true,
    },
    resize = {
      enable_default_keybindings = true,
    },
  })
end

return M
