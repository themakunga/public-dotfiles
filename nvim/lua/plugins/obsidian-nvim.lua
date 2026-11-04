local M = {}

local opts = {
  legacy_commands = false,
  picker = {
    name = 'fzf-lua',
  },
  workspaces = {
    {
      name = 'personal',
      path = '~/.vaults/personal',
    },
    {
      name = 'outcast',
      path = '~/.vaults/outcast',
    },
    {
      name = 'site-content',
      path = '~/Projects/Personal/personal-content',
    },
    {
      name = 'journal',
      path = '~/.vaults/journal/',
    },
    {
      name = 'wiki',
      path = '~/.vaults/wiki',
    },
    {
      name = 'amgmt',
      path = '~/.vaults/amgmt',
    },
  },
}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/obsidian-nvim/obsidian.nvim', version = vim.version.range('*') },
  })

  if not Checker.check('obsidian') then
    return
  end

  require('obsidian').setup(opts)
end

return M
