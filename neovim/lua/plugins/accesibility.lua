local M = {}

M.plugin = function()
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.cursorline = true
  vim.opt.title = true
  vim.opt.ruler = true
  vim.opt.showmode = true

  vim.cmd([[colorscheme desert]])

  vim.keymap.set('n', '<leader>va', function()
    vim.notify('VoiceOver: ' .. vim.fn.getline('.'), vim.log.levels.INFO)
  end, { desc = 'Announce current line' })
end

return M
