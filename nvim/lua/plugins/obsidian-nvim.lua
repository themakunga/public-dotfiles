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
      name = 'agent-wiki',
      path = '~/.vaults/agent-wiki',
    },
    {
      name = 'outcast',
      path = '~/.vaults/outcast',
    },
    {
      name = 'site-content',
      path = '~/Projects/Personal/personal-content',
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
