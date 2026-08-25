local M = {}


local keymaps = {
  -- Desactivar el espacio por defecto
  { mode = '', motion = '<Space>', cmd = '<Nop>' },

  -- ----------------------------------------
  -- NAVEGACIÓN DE VENTANAS (Normal Mode)
  -- ----------------------------------------
  { mode = 'n', motion = '<leader>h', cmd = '<C-w>h', opts = { desc = 'Move to window left' } },
  { mode = 'n', motion = '<leader>j', cmd = '<C-w>j', opts = { desc = 'Move to window down' } },
  { mode = 'n', motion = '<leader>l', cmd = '<C-w>l', opts = { desc = 'Move to window right' } },
  { mode = 'n', motion = '<leader>k', cmd = '<C-w>k', opts = { desc = 'Move to window up' } },

  -- ----------------------------------------
  -- NAVEGACIÓN DE BUFFERS
  -- ----------------------------------------
  { mode = 'n', motion = '<S-Left>', cmd = ':bprevious<CR>', opts = { desc = 'Move to previous buffer' } },
  { mode = 'n', motion = '<S-Right>', cmd = ':bnext<CR>', opts = { desc = 'Move to next buffer' } },
  { mode = 'n', motion = '<leader>bx', cmd = ':bdelete<CR>', opts = { desc = 'Close buffer' } },

  -- ----------------------------------------
  -- MOVER TEXTO
  -- ----------------------------------------
  -- Modo Normal
  { mode = 'n', motion = '<A-j>', cmd = ':m .+1<CR>==', opts = { desc = 'Move line down' } },
  { mode = 'n', motion = '<A-Down>', cmd = ':m .+1<CR>==', opts = { desc = 'Move line down' } },
  { mode = 'n', motion = '<A-k>', cmd = ':m .-2<CR>==', opts = { desc = 'Move line up' } },
  { mode = 'n', motion = '<A-Up>', cmd = ':m .-2<CR>==', opts = { desc = 'Move line up' } },

  -- Modo Visual
  { mode = 'v', motion = '<A-j>', cmd = ':m \'>+1<CR>gv=gv', opts = { desc = 'Move text up (Visual Mode)' } },
  { mode = 'v', motion = '<A-k>', cmd = ':m \'<-2<CR>gv=gv', opts = { desc = 'Move text down (Visual Mode)' } },

  -- Modo Visual Block
  { mode = 'x', motion = 'J', cmd = ':m \'>+1<CR>gv=gv', opts = { desc = 'Move text up (Visual Block Mode)' } },
  { mode = 'x', motion = 'K', cmd = ':m \'<-2<CR>gv=gv', opts = { desc = 'Move text down (Visual Block Mode)' } },
  { mode = 'x', motion = '<A-j>', cmd = ':m \'>+1<CR>gv=gv', opts = { desc = 'Copy block up' } },
  { mode = 'x', motion = '<A-k>', cmd = ':m \'<-2<CR>gv=gv', opts = { desc = 'Copy block down' } },

  -- ----------------------------------------
  -- COPIAR, CORTAR Y PEGAR
  -- ----------------------------------------
  { mode = 'n', motion = '<A-K>', cmd = ':copy .<cr>:move -2<cr>', opts = { desc = 'Duplicate line above' } },
  { mode = 'n', motion = '<A-J>', cmd = ':copy .<cr>', opts = { desc = 'Duplicate line below' } },

  -- Portapapeles del sistema (Múltiples Modos)
  { mode = { 'n', 'v' }, motion = '<leader>c', cmd = '"+y', opts = { desc = 'Copy current selection' } },
  { mode = { 'n', 'v' }, motion = '<leader>C', cmd = '"+Y', opts = { desc = 'Copy all current line in cursor' } },
  { mode = { 'n', 'v' }, motion = '<leader>d', cmd = '"+d', opts = { desc = 'Cut current selection' } },
  { mode = { 'n', 'v' }, motion = '<leader>dw', cmd = '"+dw', opts = { desc = 'Cut current word' } },
  { mode = { 'n', 'v' }, motion = '<leader>D', cmd = '"+D', opts = { desc = 'Cut until the end of the current line' } },
  { mode = { 'n', 'v' }, motion = '<leader>p', cmd = '"+p', opts = { desc = 'Paste to the cursor' } },
  { mode = { 'n', 'v' }, motion = '<leader>P', cmd = '"+P', opts = { desc = 'Paste before the cursor' } },

  -- Pegar en modo visual sin perder el portapapeles
  { mode = 'v', motion = 'p', cmd = '"_dP' },

  -- ----------------------------------------
  -- UTILIDADES VARIAS
  -- ----------------------------------------
  { mode = 'n', motion = '<leader><backspace>', cmd = ':nohlsearch<CR>', opts = { desc = 'Clear search param' } },

  -- Indentación en Visual Mode
  { mode = 'v', motion = '<', cmd = '<gv^', opts = { desc = 'Indent back' } },
  { mode = 'v', motion = '>', cmd = '>gv^', opts = { desc = 'Indent' } },

  -- Control del Editor
  { mode = 'n', motion = '<leader>o', cmd = ':update<CR> :source<CR>', opts = { desc = 'Source current file' } },
  { mode = 'n', motion = '<leader>w', cmd = ':write<CR>', opts = { desc = 'Write buffer (Save)' } },
  { mode = 'n', motion = '<leader>q', cmd = ':quit<CR>', opts = { desc = 'Quit' } },
  { mode = 'n', motion = '<leader>R', cmd = ':restart<CR>', opts = { desc = 'Restart NeoVim' } },
  { mode = 'n', motion = '<leader>so', cmd = ':source<cr>', opts = { desc = 'Source current file' } },
}


M.load = function()
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  KM.bulk_map(keymaps)
end

return M
