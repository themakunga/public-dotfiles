local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/zbirendaum/copilot.lua' },
  })

  local ok, copilot = pcall(require, 'copilot')

  if not ok then
    vim.notify('[CHECK REQUIRED FAILED] copilot ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local opts = {
    suggestion = {
      enable = true,
      auto_trigger = false,
      keymaps = {
        accept = '<Tab>',
        accept_word = '<C-Right>',
        next = '<M-]>',
        prev = '<M-[>',
        dismiss = '<C-e>',
      },
    },
    panel = {
      enable = false,
    },
    filetypes = {
      yaml = true,
      markdown = true,
      ['*'] = true,
    },
  }

  copilot.setup(opts)

  local map = vim.keymap.set

  map('n', '<leader>at', function()
    require('copilot.suggestion').toggle_auto_trigger()
  end, { desc = 'Toggle Copilot' })
end

return M
