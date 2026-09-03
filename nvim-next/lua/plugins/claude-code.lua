local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/coder/claudecode.nvim' },
  })

  if not Checker.check('claudecode') then
    return
  end

  require('claudecode').setup({})

  KM.bulk_map({
    { mode = 'n', motion = '<leader>Ac', cmd = '<cmd>ClaudeCode<cr>', opts = { desc = 'Toggle Claude' } },
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
    {
      event = 'TermOpen',
      pattern = 'term://*claude*',
      callback = function(event)
        KM.bulk_map({
          -- Salir del modo terminal → normal mode
          { mode = 't', motion = '<Esc>', cmd = '<C-\\><C-n>', opts = { desc = 'Salir modo terminal', buffer = event.buf, silent = true } },
          -- Navegar ventanas sin cerrar Claude (desde terminal mode)
          { mode = 't', motion = '<C-w>h', cmd = '<C-\\><C-n><C-w>h', opts = { desc = 'Ventana izquierda', buffer = event.buf, silent = true } },
          { mode = 't', motion = '<C-w>j', cmd = '<C-\\><C-n><C-w>j', opts = { desc = 'Ventana abajo', buffer = event.buf, silent = true } },
          { mode = 't', motion = '<C-w>k', cmd = '<C-\\><C-n><C-w>k', opts = { desc = 'Ventana arriba', buffer = event.buf, silent = true } },
          { mode = 't', motion = '<C-w>l', cmd = '<C-\\><C-n><C-w>l', opts = { desc = 'Ventana derecha', buffer = event.buf, silent = true } },
          -- Cerrar el panel desde normal mode
          { mode = 'n', motion = 'q', cmd = '<cmd>close<cr>', opts = { desc = 'Cerrar Claude', buffer = event.buf, silent = true } },
        })
      end,
    },
  })
end

return M
