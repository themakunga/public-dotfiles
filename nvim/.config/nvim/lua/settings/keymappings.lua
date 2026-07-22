local M = {}

M.init = function()
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  local map = vim.keymap.set

  vim.keymap.set('', '<Space>', '<Nop>')

  -- Modes
  --   normal_mode = "n",
  --   insert_mode = "i",
  --   visual_mode = "v",
  --   visual_block_mode = "x",
  --   term_mode = "t",
  --   command_mode = "c",

  -- better windows navigation
  -- Normal --
  -- Better window navigation
  map('n', '<leader>h', '<C-w>h', { desc = 'Move to window left' })
  map('n', '<leader>j', '<C-w>j', { desc = 'Move to window up' })
  map('n', '<leader>l', '<C-w>l', { desc = 'Move to window right' })
  map('n', '<leader>k', '<C-w>k', { desc = 'Move to window down' })

  -- Resize with arrows
  -- map("n", "<C-Up>", ":resize -2<CR>", {desc = 'Resize window '})
  -- map("n", "<C-Down>", ":resize +2<CR>", {desc = ''})
  -- map("n", "<C-Left>", ":vertical resize -2<CR>", {desc = ''})
  -- map("n", "<C-Right>", ":vertical resize +2<CR>", {desc = ''})

  -- Navigate buffers
  -- map("n", "<S-l>", ":bprevious<CR>", {desc = ''})
  map('n', '<S-Left>', ':bprevious<CR>', { desc = 'Move to previous buffer' })
  -- map("n", "<S-h>", ":bnext<CR>", {desc = ''})
  map('n', '<S-Right>', ':bnext<CR>', { desc = 'Move to next buffer' })
  map('n', '<leader>bx', ':bdelete<CR>', { desc = 'Close buffer' })
  -- Move text up and down
  map('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
  map('n', '<A-Down>', ':m .+1<CR>==', { desc = 'Move line down' })
  map('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
  map('n', '<A-Up>', ':m .-2<CR>==', { desc = 'Move line up' })

  -- Copy text
  map('n', '<A-K>', ':copy .<cr>:move -2<cr>', { desc = 'Copy current line down' })
  map('n', '<A-J>', ':copy .<cr>', { desc = 'Copy current line up' })
  map('n', '<leader><backspace>', ':nohlsearch<CR>', { desc = 'Clear search param' })
  -- Insert --
  -- Press jk fast to exit insert mode
  -- map("i", "jk", "<ESC>", {desc = ''})
  -- map("i", "kj", "<ESC>", {desc = ''})

  map({ 'n', 'v' }, '<leader>c', '"+y', { desc = 'Copy current selection' })
  map({ 'n', 'v' }, '<leader>C', '"+Y', { desc = 'Copy all current line in cursor' })
  map({ 'n', 'v' }, '<leader>d', '"+d', { desc = 'Cut current selection' })
  map({ 'n', 'v' }, '<leader>dw', '"+dw', { desc = 'Cut current word' })
  map({ 'n', 'v' }, '<leader>D', '"+D', { desc = 'Cut until the end of the current line' })
  map({ 'n', 'v' }, '<leader>p', '"+p', { desc = 'Paste to the cursor' })
  map({ 'n', 'v' }, '<leader>P', '"+P', { desc = 'Paste before the cursor' })

  -- Visual --
  -- Stay in indent mode
  map('v', '<', '<gv^', { desc = 'Indent back' })
  map('v', '>', '>gv^', { desc = 'Indent' })

  -- Move text up and down
  map('v', '<A-j>', ':m \'>+1<CR>gv=gv', { desc = 'Move text up (Visual Mode)' })
  map('v', '<A-k>', ':m \'<-2<CR>gv=gv', { desc = 'Move text down (Visual Mode)' })
  map('v', 'p', '"_dP')

  -- Visual Block --
  -- Move text up and down
  map('x', 'J', ':m \'>+1<CR>gv=gv', { desc = 'Move text up (Visual Block Mode)' })
  map('x', 'K', ':m \'<-2<CR>gv=gv', { desc = 'Move text down (Visual Block Mode)' })
  map('x', '<A-j>', ':m \'>+1<CR>gv=gv', { desc = 'Copy block up' })
  map('x', '<A-k>', ':m \'<-2<CR>gv=gv', { desc = 'Copy block down' })

  -- utils
  -- Source current file
  map('n', '<leader>o', ':update<CR> :source<CR>', { desc = 'Source current file' })
  map('n', '<leader>w', ':write<CR>', { desc = 'Write buffer (Save)' })
  map('n', '<leader>q', ':quit<CR>', { desc = 'Quit' })

  map('n', '<leader>R', ':restart<CR>', { desc = 'Restart NeoVim' })
  map('n', '<leader>so', ':source<cr>', { desc = 'Source current file' })
end

return M
