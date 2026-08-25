local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/f-person/git-blame.nvim' },
  })

  if not Checker.check('gitblame') then
    return
  end

  local opts = {
    enabled = false,
    message_template = ' <summary> • <date> • <author> • <<sha>>',
    message_when_not_committed = 'Oh please, commit this !',
    date_format = '%Y-%m-%d %H:%M:%S',
    virtual_text_column = 1,
  }

  require('gitblame').setup(opts)

  KM.bulk_map({
    { motion = '<leader>gbe', cmd = ':GitBlameEnable<CR>', opts = { desc = 'iGitBlame Enable' } },
    { motion = '<leader>gbd', cmd = ':GitBlameDisable<CR>', opts = { desc = 'GitBlame Disable' } },
    { motion = '<leader>gbt', cmd = ':GitBlameToggle<CR>', opts = { desc = 'GitBlame Toggle' } },
    { motion = '<leader>gbS', cmd = ':GitBlameCopySHA<CR>', opts = { desc = 'GitBlame Copy SHA' } },
    { motion = '<leader>gbU', cmd = ':GitBlameCopyCommitURL<CR>', opts = { desc = 'GitBlame Copy commit URL' } },
    { motion = '<leader>gbP', cmd = ':GitBlameCopyPRURL<CR>', opts = { desc = 'GitBlame Copy PR URL' } },
    { motion = '<leader>gbo', cmd = ':GitBlameOpenFileURL<CR>', opts = { desc = 'GitBlame open file URL' } },
    { motion = '<leader>gbc', cmd = ':GitBlameCopyFileURL<CR>', opts = { desc = 'GitBlame copy file URL' } },
    { motion = '<leader>gbu', cmd = ':GitBlameOpenCommitURL<CR>', opts = { desc = 'GitBlame open commit URL' } },
  })
end

return M
