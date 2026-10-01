-- Run: nvim --headless -u NONE -i NONE -l tests/todotxt.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.cmd.packadd('todotxt.nvim')
vim.cmd.packadd('nvim-treesitter')
require('nvim-treesitter').setup({})
require('plugins.nvim-treesitter.filetypes').setup()
_G.CMD = require('core.cmd')
require('plugins.nvim-treesitter.features').setup()

-- Keep the plugin's default todo file inside a temporary home.
local home = vim.fn.tempname()
vim.fn.mkdir(home .. '/Documents', 'p')
vim.env.HOME = home
require('todotxt').setup({})
vim.cmd('filetype on')

assert(vim.filetype.match({ filename = '/tmp/done.txt' }) == 'todotxt')
assert(vim.filetype.match({ filename = '/tmp/notes.txt' }) == 'text')
vim.cmd.edit(home .. '/Documents/todo.txt')
vim.api.nvim_buf_set_lines(0, 0, -1, false, { '(A) Test +project @home', 'x 2026-10-01 Done' })
assert(vim.bo.filetype == 'todotxt')
assert(
  vim.wait(3000, function()
    return #vim.lsp.get_clients({ bufnr = 0, name = 'todotxt' }) == 1
  end),
  'todo.txt LSP did not attach'
)
local client = vim.lsp.get_clients({ bufnr = 0, name = 'todotxt' })[1]
assert(client:supports_method('textDocument/completion'))
assert(client:supports_method('textDocument/rename'))
assert(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()])
assert(not vim.treesitter.get_parser(0, 'todotxt'):parse()[1]:root():has_error())
vim.fn.delete(home, 'rf')
print('todo.txt LSP and Treesitter: OK')
