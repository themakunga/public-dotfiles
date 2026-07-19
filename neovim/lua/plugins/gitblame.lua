local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/f-person/git-blame.nvim' },
  })

  ---@module 'gitblame'
  local ok, gitblame = pcall(require, 'gitblame')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] gitblame ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local opts = {
    enabled = false,
    message_template = ' <summary> • <date> • <author> • <<sha>>',
    message_when_not_committed = 'Oh please, commit this !',
    date_format = '%Y-%m-%d %H:%M:%S',
    virtual_text_column = 1,
  }

  gitblame.setup(opts)

  vim.keymap.set('n', '<leader>gbe', ':GitBlameEnable<cr>', { desc = 'GitBlame enable' })
  vim.keymap.set('n', '<leader>gbd', ':GitBlameDisable <cr>', { desc = 'GitBlame disable' })
  vim.keymap.set('n', '<leader>gbt', ':GitBlameToggle <cr>', { desc = 'GitBlame toggle' })
  vim.keymap.set('n', '<leader>gbS', ':GitBlameCopySHA <cr>', { desc = 'GitBlame copy SHA' })
  vim.keymap.set('n', '<leader>gbU', ':GitBlameCopyCommitURL <cr>', { desc = 'GitBlame copy commit URL' })
  vim.keymap.set('n', '<leader>gbP', ':GitBlameCopyPRURL<cr>', { desc = 'GitBlame copy PR URL' })
  vim.keymap.set('n', '<leader>gbo', ':GitBlameOpenFileURL<cr>', { desc = 'GitBlame open file URL' })
  vim.keymap.set('n', '<leader>gbc', ':GitBlameCopyFileURL<cr>', { desc = 'GitBlame copy file URL' })
  vim.keymap.set('n', '<leader>gbu', ':GitBlameOpenCommitURL <cr>', { desc = 'GitBlame open commit URL' })
end

return M
