local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/lemarsu/sops.nvim' },
  })

  local ok, sops_config = pcall(require, 'sops.config')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] sops ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  -- AHORA APUNTAMOS AL ARCHIVO CONVERTIDO DE AGE
  local age_key_path = vim.fn.expand('~/.config/sops/age/keys.txt')

  sops_config.env = {
    SOPS_AGE_KEY_FILE = age_key_path,
  }

  sops_config.follow = {
    'SOPS_AGE_KEY_FILE',
  }

  vim.keymap.set('n', '<leader>Se', ':Sops edit<cr>', { desc = 'Edit with sops' })
  vim.keymap.set('n', '<leader>Sc', ':Sops close<cr>', { desc = 'Close sops session' })
  vim.keymap.set('n', '<leader>St', ':Sops toggle<cr>', { desc = 'Toggle sops edit' })
  vim.keymap.set('n', '<leader>Sx', ':Sops encrypt<cr>', { desc = 'Encrypt with sops' })
  vim.keymap.set('n', '<leader>Sd', ':Sops decrypt<cr>', { desc = 'Decrypt with sops' })
  vim.keymap.set('n', '<leader>Sv', ':Sops version<cr>', { desc = 'Show sops.nvim version' })
end

return M
