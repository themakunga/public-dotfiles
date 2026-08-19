loca M = {}

local globals = vim.g

local bulk = require('utils.keymap').bulk_map()

  -- Modes
  --   normal_mode = "n",
  --   insert_mode = "i",
  --   visual_mode = "v",
  --   visual_block_mode = "x",
  --   term_mode = "t",
  --   command_mode = "c",


local maplist = {
  -- {'n', '<leader>', '', ''},
  {"i", "jk", "<ESC>", "Close insert mode"},
  {"i", "kj", "<ESC>", "Close insert mode"},
  -- better windows navigation
  {'n', '<leader>h', '<C-w>h', 'Move to window left'},
  {'n', '<leader>j', '<C-w>j', 'Move to window up'},
  {'n', '<leader>l', '<C-w>l', 'Move to window right'},
  {'n', '<leader>k', '<C-w>k', 'Move to window down'},
  -- Resize with arrows
  {'n', '<C-Up>', ':resize -2<CR>', 'Resize window'},
  {'n', '<C-Down>', ':resize +2<CR>', ''},
  {'n', '<C-Left>', ':vertical resize -2<CR>', ''},
  {'n', '<C-Right>', ':vertical resize +2<CR>', ''},
  -- Navigate buffers
  {"n", "<S-p>", ":bprevious<CR>", 'Move to previous buffer'},
  {'n', '<S-Left>', ':bprevious<CR>','Move to previous buffer'}
  {'n', '<S-n>', ':bnext<CR>', 'Move to next buffer'},
  {'n', '<S-Right>', ':bnext<CR>', 'Move to next buffer'},
  {'n', '<leader>bx', ':bdelete<CR>', 'Close buffer'},
  -- Move text
  {'n', '<A-j>', ':m .+1<CR>==','Move line down'},
  {'n', '<A-Down>', ':m .+1<CR>==', 'Move line down'},
  {'n', '<A-k>', ':m .-2<CR>==','Move line up'},
  {'n', '<A-Up>', ':m .-2<CR>==','Move line up'},
  -- Copy text
  {'n', '<A-K>', ':copy .<cr>:move -2<cr>', 'Copy current line down'},
  {'n', '<A-J>', ':copy .<cr>', 'Copy current line up'},
  {'n', '<leader><backspace>', ':nohlsearch<CR>', 'Clear search param'},
  -- Insert text


}

M.load = function()

  globals.mapleader = ' '
  globals.maplocalleader = ' '

  bulk(maplist)

end

return M
