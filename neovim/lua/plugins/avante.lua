local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/yetone/avante.nvim' },
    { src = 'https://github.com/stevearc/dressing.nvim' },
  })

  local to_check = {
    'avante',
    'dressing',
  }

  local ok = require('utils.check-requires').check(to_check)

  if not ok then
    return
  end

  local avante = require('avante')

  local opts = {
    provider = 'claude',
    claude = {
      endpoint = 'https://api.anthropic.com',
      model = 'claude-sonnet-4-6',
      api_key = os.getenv('ANTHOPIC_API_KEY'),
    },

    -- provider= 'openai',
    -- openai = {
    --   endpoint = 'https://api.openai.com/v1',
    --   model = 'gpt-4o',
    --   api_key = os.getenv('OPENAI_API_KEY'),
    --   timeout = 30000,
    -- },
    -- provider = 'ollama',
    -- vendors = {
    --   ollama = {
    --     __inherited_from = 'openai',
    --     api_ket_name = '',
    --     endpoint = 'https://localhost:11434/v1',
    --     model = 'gemma4:12b',
    --   },
    -- },
    behaviour = {
      auto_suggestions = false,
      aauto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
    },
    windows = {
      position = 'right',
      width = 35,
    },
  }

  avante.setup(opts)

  local map = vim.keymap.set

  map('n', '<leader>aa', '<cmd>AvanteAsk<CR>', { desc = 'AI Ask' })
  map('n', '<leader>ae', '<cmd>AvanteEdit<CR>', { desc = 'AI Edit' })
  map('n', '<leader>ar', '<cmd>AvanteRefresh<CR>', { desc = 'AI Refresh' })
  map('v', '<leader>ae', '<cmd>AvanteEdit<CR>', { desc = 'AI Edit selection' })
end

return M
