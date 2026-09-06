local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/lemarsu/sops.nvim' },
  })

  if not Checker.check('sops.config') then
    return
  end

  local age_key_path = vim.fn.expand('~/.config/sops/age/keys.txt')

  require('sops.config').env = {
    SOPS_AGE_KEY_FILE = age_key_path,
  }

  require('sops.config').follow = {
    'SOPS_AGE_KEY_FILE',
  }

  KM.bulk_map({
    { motion = '<leader>Se', cmd = ':Sops edit<cr>', opts = { desc = 'Edit with sops' } },
    { motion = '<leader>Sc', cmd = ':Sops close<cr>', opts = { desc = 'Close sops session' } },
    { motion = '<leader>St', cmd = ':Sops toggle<cr>', opts = { desc = 'Toggle sops edit' } },
    { motion = '<leader>Sx', cmd = ':Sops encrypt<cr>', opts = { desc = 'Encrypt with sops' } },
    { motion = '<leader>Sd', cmd = ':Sops decrypt<cr>', opts = { desc = 'Decrypt with sops' } },
    { motion = '<leader>Sv', cmd = ':Sops version<cr>', opts = { desc = 'Show sops.nvim version' } },
  })
end

return M
