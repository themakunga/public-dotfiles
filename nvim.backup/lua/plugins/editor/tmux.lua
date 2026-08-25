local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/aserowy/tmux.nvim' },
    { src = 'https://github.com/christoomey/vim-tmux-navigator' },
  })

  ---@module 'tmux'
  local ok_tmux, tmux = pcall(require, 'tmux')

  if not ok_tmux then
    vim.notify('[CHECK REQUIRE FAILED] tmux ' .. debug.getinfo(2).source, vim.log.levels.WARN)
  else
    tmux.setup({
      resize = {
        enable_default_keybindings = true,
      },
    })
  end

  -- vim-tmux-navigator is a Vimscript plugin and does not need a Lua require/setup step.
  -- We just define the keybindings for its commands.
  vim.keymap.set('n', '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>', { silent = true, desc = 'Tmux Navigate Left' })
  vim.keymap.set('n', '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>', { silent = true, desc = 'Tmux Navigate Down' })
  vim.keymap.set('n', '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>', { silent = true, desc = 'Tmux Navigate Up' })
  vim.keymap.set('n', '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>', { silent = true, desc = 'Tmux Navigate Right' })
  vim.keymap.set(
    'n',
    '<c-\\>',
    '<cmd><C-U>TmuxNavigatePrevious<cr>',
    { silent = true, desc = 'Tmux Navigate Previous' }
  )
end

return M
