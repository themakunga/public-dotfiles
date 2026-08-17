--- Archivo: ./lua/plugins/coding/codecompanion.lua
local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/olimorris/codecompanion.nvim' },
  })

  local ok, codecompanion = pcall(require, 'codecompanion')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] codecompanion ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  codecompanion.setup({
    adapters = {
      anthropic = function()
        return require('codecompanion.adapters').extend('anthropic', {
          env = { api_key = 'ANTHROPIC_API_KEY' },
          schema = {
            model = {
              default = 'claude-sonnet-4-5',
            },
          },
        })
      end,
    },
    strategies = {
      chat = { adapter = 'anthropic' },
      inline = { adapter = 'anthropic' },
      agent = { adapter = 'anthropic' },
    },
    display = {
      diff = { provider = 'mini_diff' },
      chat = {
        window = {
          layout = 'vertical',
          width = 0.35,
        },
      },
    },
  })

  local map = vim.keymap.set

  map({ 'n', 'v' }, '<leader>ai', '<cmd>CodeCompanionChat Toggle<cr>', { desc = 'AI Chat (Toggle)' })
  map({ 'n', 'v' }, '<leader>aa', '<cmd>CodeCompanionActions<cr>', { desc = 'AI Actions' })
  map('v', '<leader>as', '<cmd>CodeCompanionChat Add<cr>', { desc = 'AI Add to Chat' })
  map('n', '<leader>an', '<cmd>CodeCompanionChat<cr>', { desc = 'AI New Chat' })
end

return M
