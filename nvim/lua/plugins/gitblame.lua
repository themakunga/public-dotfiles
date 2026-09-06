local M = {}

local opts = {
  enabled = false,
  message_template = ' <summary> • <date> • <author> • <<sha>>',
  message_when_not_committed = 'Oh please, commit this !',
  date_format = '%Y-%m-%d %H:%M:%S',
  virtual_text_column = 1,
}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/f-person/git-blame.nvim' },
  })

  if not Checker.check('gitblame') then
    return
  end

  require('gitblame').setup(opts)

  KM.bulk_map({
    { motion = '<leader>gbe', cmd = ':GitBlameEnable<cr>', opts = { desc = 'GitBlame enable' } },
    { motion = '<leader>gbd', cmd = ':GitBlameDisable <cr>', opts = { desc = 'GitBlame disable' } },
    { motion = '<leader>gbt', cmd = ':GitBlameToggle <cr>', opts = { desc = 'GitBlame toggle' } },
    { motion = '<leader>gbS', cmd = ':GitBlameCopySHA <cr>', opts = { desc = 'GitBlame copy SHA' } },
    { motion = '<leader>gbU', cmd = ':GitBlameCopyCommitURL <cr>', opts = { desc = 'GitBlame copy commit URL' } },
    { motion = '<leader>gbP', cmd = ':GitBlameCopyPRURL<cr>', opts = { desc = 'GitBlame copy PR URL' } },
    { motion = '<leader>gbo', cmd = ':GitBlameOpenFileURL<cr>', opts = { desc = 'GitBlame open file URL' } },
    { motion = '<leader>gbc', cmd = ':GitBlameCopyFileURL<cr>', opts = { desc = 'GitBlame copy file URL' } },
    { motion = '<leader>gbu', cmd = ':GitBlameOpenCommitURL <cr>', opts = { desc = 'GitBlame open commit URL' } },
  })
end

return M
