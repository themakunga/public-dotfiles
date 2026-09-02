local M = {}

-- Agnóstico de provider: Ollama (local) como default, Anthropic como alternativa.
-- Selección vía env var AI_ADAPTER=ollama|anthropic o en tiempo de ejecución con
-- :CodeCompanionChat anthropic / :CodeCompanionChat ollama
--
-- Variables de entorno requeridas:
--   ANTHROPIC_API_KEY  → para Claude (Anthropic)
--   OLLAMA_API_URL     → URL de Ollama (default: http://127.0.0.1:11434)
--   OLLAMA_MODEL       → modelo (default: llama3.1:latest)

local default_adapter = vim.env.AI_ADAPTER or 'ollama'

local adapters = {
  anthropic = function()
    return require('codecompanion.adapters').extend('anthropic', {
      env = {
        api_key = 'ANTHROPIC_API_KEY',
      },
      schema = {
        model = {
          default = 'claude-sonnet-4-5',
        },
      },
    })
  end,

  ollama = function()
    return require('codecompanion.adapters').extend('ollama', {
      env = {
        url = vim.env.OLLAMA_API_URL or 'http://127.0.0.1:11434',
      },
      schema = {
        model = {
          default = vim.env.OLLAMA_MODEL or 'llama3.1:latest',
        },
        num_ctx = {
          default = 16384,
        },
      },
    })
  end,
}

-- Prefijo <leader>a — sin conflicto con <leader>ca (LSP code action)
local keymaps = {
  {
    mode = 'n',
    motion = '<leader>ai',
    cmd = '<cmd>CodeCompanionChat Toggle<cr>',
    opts = { desc = 'AI: Toggle Chat' },
  },
  {
    mode = { 'n', 'v' },
    motion = '<leader>aa',
    cmd = '<cmd>CodeCompanionChat Add<cr>',
    opts = { desc = 'AI: Add selección al Chat' },
  },

  {
    mode = { 'n', 'v' },
    motion = '<leader>ac',
    cmd = '<cmd>CodeCompanion<cr>',
    opts = { desc = 'AI: Inline Assistant' },
  },

  {
    mode = { 'n', 'v' },
    motion = '<leader>ap',
    cmd = '<cmd>CodeCompanionActions<cr>',
    opts = { desc = 'AI: Actions Palette' },
  },
}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/olimorris/codecompanion.nvim' },
  })

  if not Checker.check('codecompanion') then
    return
  end

  require('codecompanion').setup({
    adapters = adapters,

    strategies = {
      chat = {
        adapter = default_adapter,
        keymaps = {
          send = {
            modes = { n = '<CR>', i = '<C-CR>' },
            opts = { desc = 'Enviar mensaje' },
          },
          close = {
            modes = { n = '<leader>q' },
            opts = { desc = 'Cerrar chat' },
          },
        },
      },
      inline = {
        adapter = default_adapter,
        keymaps = {
          accept_change = {
            modes = { n = '<leader>ay' },
            opts = { desc = 'AI: Aceptar cambio inline' },
          },
          reject_change = {
            modes = { n = '<leader>an' },
            opts = { desc = 'AI: Rechazar cambio inline' },
          },
        },
      },
      agent = {
        adapter = default_adapter,
      },
    },

    display = {
      chat = {
        window = {
          layout = 'vertical',
          width = 0.35,
          border = 'rounded',
        },
        show_token_count = true,
        render_headers = true,
      },
      inline = {
        layout = 'vertical',
        diff = {
          enabled = true,
          close_chat_at = 240,
          layout = 'vertical',
          opts = { 'internal', 'filler', 'closeoff', 'algorithm:patience' },
        },
      },
      action_palette = {
        width = 95,
        height = 10,
        prompt = 'Acción AI > ',
        provider = 'default',
      },
    },

    opts = {
      log_level = 'ERROR',
      send_code = true,
      use_default_actions = true,
      use_default_prompt_library = true,
    },
  })

  -- Abreviatura de comando: 'cc' → 'CodeCompanion'
  vim.cmd('cab cc CodeCompanion')

  KM.bulk_map(keymaps)
end

return M
