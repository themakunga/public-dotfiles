local M = {}

local globals = {
  loaded_netrw = 1,
  loaded_netrwPlugin = 1,
  have_nerd_font = true,
  loaded_node_provider = 0,
  loaded_perl_provider = 0,
  loaded_python3_provider = 0,
  loaded_ruby_provider = 0,
}

local opt_actions = {
  shortmess = { append = 'c' },
  iskeyword = { append = '-' },
  formatoptions = { remove = { 'c', 'r', 'o' } },
  runtimepath = { remove = '/usr/share/vim/vimfiles' },
}

local options = {
  backup = false,
  clipboard = 'unnamedplus',
  completeopt = { 'menuone', 'noselect' },
  conceallevel = 0,
  fileencoding = 'utf-8',
  hlsearch = true,
  ignorecase = true,
  mouse = 'a',
  pumheight = 10,
  showmode = false, -- we don't need to see things like -- INSERT -- anymore
  showtabline = 2, -- always show tabs
  smartcase = true,
  smartindent = true,
  splitbelow = true, -- force all horizontal splits to go below current window
  splitright = true, -- force all vertical splits to go to the right of current window
  swapfile = false,
  termguicolors = true,
  timeoutlen = 500, -- time to wait for a mapped sequence to complete (in milliseconds)
  undofile = true,
  updatetime = 300, -- faster completion (4000ms default)
  writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
  expandtab = true,
  shiftwidth = 2,
  tabstop = 2,
  cursorline = true,
  number = true,
  relativenumber = true,
  numberwidth = 4,

  signcolumn = 'yes', -- always show the sign column, otherwise it would shift the text each time
  wrap = true,
  linebreak = true, -- companion to wrap, don't split words
  scrolloff = 8,
  sidescrolloff = 8,
  guifont = 'monospace:h17',
  whichwrap = 'bs<>[]hl', -- which "horizontal" keys are allowed to travel to prev/next line
  winborder = 'rounded',
}

M.load = function()
  for k, v in pairs(options) do
    vim.opt[k] = v
  end

  for key, value in pairs(globals) do
    vim.g[key] = value
  end

  for opt, actions in pairs(opt_actions) do
    for action, value in pairs(actions) do
      vim.opt[opt][action](vim.opt[opt], value)
    end
  end
end

return M
