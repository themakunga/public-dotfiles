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
        width = 0.95,
        height = 0.3,
        row = 1, -- snacks: row=1 → top of window en el borde inferior (como toggleterm)
        col = 0.5,
        zindex = 50,
        border = 'curved',
        title = ' Claude Code ',
        title_pos = 'center',
      },
    },
  })

  KM.bulk_map({
    { mode = 'n', motion = '<leader>ACt', cmd = '<cmd>ClaudeCode<cr>',            opts = { desc = 'Toggle Claude' } },
    { mode = 'n', motion = '<M-c>',       cmd = '<cmd>ClaudeCode<cr>',            opts = { desc = 'Toggle Claude (global)' } },
    { mode = 't', motion = '<M-c>',       cmd = '<C-\\><C-n><cmd>ClaudeCode<cr>', opts = { desc = 'Ocultar Claude sin cerrar sesión' } },
    { mode = 'n', motion = '<leader>ACf', cmd = '<cmd>ClaudeCodeFocus<cr>',       opts = { desc = 'Focus Claude' } },
    { mode = 'n', motion = '<leader>ACr', cmd = '<cmd>ClaudeCode --resume<cr>',   opts = { desc = 'Resume Claude' } },
    { mode = 'n', motion = '<leader>ACC', cmd = '<cmd>ClaudeCode --continue<cr>', opts = { desc = 'Continue Claude' } },
    { mode = 'n', motion = '<leader>ACm', cmd = '<cmd>ClaudeCodeSelectModel<cr>', opts = { desc = 'Select Claude model' } },
    { mode = 'n', motion = '<leader>ACb', cmd = '<cmd>ClaudeCodeAdd %<cr>',       opts = { desc = 'Add current buffer' } },
    { mode = 'v', motion = '<leader>ACs', cmd = '<cmd>ClaudeCodeSend<cr>',        opts = { desc = 'Send to Claude' } },
    -- Diff management
    { mode = 'n', motion = '<leader>ACa', cmd = '<cmd>ClaudeCodeDiffAccept<cr>',  opts = { desc = 'Accept diff' } },
    { mode = 'n', motion = '<leader>ACd', cmd = '<cmd>ClaudeCodeDiffDeny<cr>',    opts = { desc = 'Deny diff' } },
  })

  CMD.aucmd('claude-code', {
    {
      event = 'FileType',
      pattern = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw', 'snacks_picker_list' },
      callback = function(event)
        vim.keymap.set('n', '<leader>ACs', '<cmd>ClaudeCodeTreeAdd<cr>', {
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
          { mode = 't', motion = '<Esc>',   cmd = '<C-\\><C-n>',              opts = { desc = 'Salir modo terminal',  buffer = event.buf, silent = true } },
          -- Ocultar sin cerrar la sesión (x y q son equivalentes)
          { mode = 'n', motion = 'x',       cmd = '<cmd>ClaudeCode<cr>',      opts = { desc = 'Ocultar Claude',       buffer = event.buf, silent = true } },
          { mode = 'n', motion = 'q',       cmd = '<cmd>ClaudeCode<cr>',      opts = { desc = 'Ocultar Claude',       buffer = event.buf, silent = true } },
          -- Navegar ventanas sin cerrar Claude (desde terminal mode)
          { mode = 't', motion = '<C-w>h',  cmd = '<C-\\><C-n><C-w>h',       opts = { desc = 'Ventana izquierda',    buffer = event.buf, silent = true } },
          { mode = 't', motion = '<C-w>j',  cmd = '<C-\\><C-n><C-w>j',       opts = { desc = 'Ventana abajo',        buffer = event.buf, silent = true } },
          { mode = 't', motion = '<C-w>k',  cmd = '<C-\\><C-n><C-w>k',       opts = { desc = 'Ventana arriba',       buffer = event.buf, silent = true } },
          { mode = 't', motion = '<C-w>l',  cmd = '<C-\\><C-n><C-w>l',       opts = { desc = 'Ventana derecha',      buffer = event.buf, silent = true } },
        })
      end,
    },
  })
end

return M
