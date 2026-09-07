local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/coder/claudecode.nvim' },
  })

  if not Checker.check('claudecode') then
    return
  end

  require('claudecode').setup({
    terminal = {
      provider = 'snacks',
      snacks_win_opts = {
        position = 'float',
        relative = 'editor',
        border = 'rounded',
        width = 0.38,
        height = 0.90,
        row = 0,
        col = 0,
        zindex = 50,
      },
    },
  })

  KM.bulk_map({
    { mode = 'n', motion = '<leader>Ac', cmd = '<cmd>ClaudeCode<cr>', opts = { desc = 'Toggle Claude' } },
    { mode = 'n', motion = '<M-c>', cmd = '<cmd>ClaudeCode<cr>', opts = { desc = 'Toggle Claude (global)' } },
    -- Desde dentro del terminal: <C-\><C-n> sale de insert-mode sin enviar Esc al proceso
    { mode = 't', motion = '<M-c>', cmd = '<C-\\><C-n><cmd>ClaudeCode<cr>', opts = { desc = 'Ocultar Claude sin cerrar sesión' } },
    { mode = 'n', motion = '<leader>Af', cmd = '<cmd>ClaudeCodeFocus<cr>', opts = { desc = 'Focus Claude' } },
    { mode = 'n', motion = '<leader>Ar', cmd = '<cmd>ClaudeCode --resume<cr>', opts = { desc = 'Resume Claude' } },
    { mode = 'n', motion = '<leader>AC', cmd = '<cmd>ClaudeCode --continue<cr>', opts = { desc = 'Continue Claude' } },
    {
      mode = 'n',
      motion = '<leader>Am',
      cmd = '<cmd>ClaudeCodeSelectModel<cr>',
      opts = { desc = 'Select Claude model' },
    },
    { mode = 'n', motion = '<leader>Ab', cmd = '<cmd>ClaudeCodeAdd %<cr>', opts = { desc = 'Add current buffer' } },
    { mode = 'v', motion = '<leader>As', cmd = '<cmd>ClaudeCodeSend<cr>', opts = { desc = 'Send to Claude' } },

    -- Diff management
    { mode = 'n', motion = '<leader>Aa', cmd = '<cmd>ClaudeCodeDiffAccept<cr>', opts = { desc = 'Accept diff' } },
    { mode = 'n', motion = '<leader>Ad', cmd = '<cmd>ClaudeCodeDiffDeny<cr>', opts = { desc = 'Deny diff' } },
  })

  CMD.aucmd('claude-code', {
    {
      event = 'FileType',
      pattern = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw', 'snacks_picker_list' },
      callback = function(event)
        vim.keymap.set('n', '<leader>As', '<cmd>ClaudeCodeTreeAdd<cr>', {
          buffer = event.buf,
          desc = 'Add file to Claude',
          silent = true,
        })
      end,
    },
  })
end

return M
