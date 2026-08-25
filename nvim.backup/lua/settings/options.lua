local M = {}

M.init = function()
  local opt = vim.opt

  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
  vim.g.have_nerd_font = true
  vim.g.loaded_node_provider = 0
  vim.g.loaded_perl_provider = 0
  vim.g.loaded_python3_provider = 0
  vim.g.loaded_ruby_provider = 0

  vim.opt.shortmess:append('c')
  vim.opt.iskeyword:append('-')
  vim.opt.formatoptions:remove({ 'c', 'r', 'o' })
  vim.opt.runtimepath:remove('/usr/share/vim/vimfiles')

  local options = {
    backup = false,
    clipboard = 'unnamedplus',
    completeopt = { 'menuone', 'noselect', 'popup', 'fuzzy' },
    conceallevel = 0,
    cursorline = true, -- highlight the current line
    expandtab = true, -- convert tabs to spaces
    fileencoding = 'utf-8',
    guifont = 'monospace:h17', -- the font used in graphical neovim applications
    hlsearch = true,
    ignorecase = true,
    linebreak = true, -- companion to wrap, don't split words
    mouse = 'a',
    number = true, -- set numbered lines
    numberwidth = 4, -- set number column width to 2 {default 4}
    pumheight = 10, -- pop up menu height
    relativenumber = true, -- set relative numbered lines
    scrolloff = 8, -- minimal number of screen lines to keep above and below the cursor
    shiftwidth = 2, -- the number of spaces inserted for each indentation
    showmode = false, -- we don't need to see things like -- INSERT -- anymore
    showtabline = 2, -- always show tabs
    sidescrolloff = 8, -- minimal number of screen columns either side of cursor if wrap is `false`
    signcolumn = 'yes', -- always show the sign column, otherwise it would shift the text each time
    smartcase = true, -- smart case
    smartindent = true, -- make indenting smarter again
    splitbelow = true, -- force all horizontal splits to go below current window
    splitright = true, -- force all vertical splits to go to the right of current window
    swapfile = false, -- creates a swapfile
    tabstop = 2, -- insert 2 spaces for a tab
    termguicolors = true, -- set term gui colors (most terminals support this)
    timeoutlen = 300, -- time to wait for a mapped sequence to complete (in milliseconds)
    undofile = true, -- enable persistent undo
    updatetime = 300, -- faster completion (4000ms default)
    whichwrap = 'bs<>[]hl', -- which "horizontal" keys are allowed to travel to prev/next line
    winborder = 'rounded',
    wrap = true, -- display lines as one long line
    writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
  }

  for key, value in pairs(options) do
    opt[key] = value
  end
end

return M
