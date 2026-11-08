-- Run: nvim --headless -u NONE -i NONE -l tests/todotxt.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.rtp:append(vim.fn.getcwd() .. '/after')
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
-- Exercise the real configuration without downloading packages.
local pack_add, checker = vim.pack.add, _G.Checker
vim.pack.add = function() end
_G.Checker = {
  check = function()
    return true
  end,
}
require('plugins.todotxt').plugin()
vim.pack.add, _G.Checker = pack_add, checker
vim.cmd('filetype on')

assert(vim.filetype.match({ filename = '/tmp/done.txt' }) == 'todotxt')
assert(vim.filetype.match({ filename = '/tmp/work-todo.txt' }) == 'todotxt')
assert(vim.filetype.match({ filename = '/tmp/done-work.txt' }) == 'todotxt')
assert(vim.filetype.match({ filename = '/tmp/notes.txt' }) == 'text')
vim.cmd.edit(home .. '/Documents/todo.txt')
local lines = {
  '(A) 2026-10-01 Test +project @home due:2026-12-01',
  '(B) Next task',
  '(C) Later task',
  '(D) Other priority',
  'x 2026-10-01 Done +project @home',
  '',
  '   ',
}
vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
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
local function has_capture(row, col, name)
  vim.treesitter.get_parser(0, 'todotxt'):parse()
  return vim.iter(vim.treesitter.get_captures_at_pos(0, row, col)):any(function(capture)
    return capture.capture == name
  end)
end
assert(has_capture(0, 1, 'comment.error'))
assert(has_capture(1, 1, 'comment.warning'))
assert(has_capture(2, 1, 'comment.note'))
assert(has_capture(3, 1, 'keyword'))
assert(not has_capture(3, 1, 'comment.error'))
assert(has_capture(0, lines[1]:find('+project', 1, true) - 1, 'string'))
assert(has_capture(0, lines[1]:find('@home', 1, true) - 1, 'type'))
assert(has_capture(0, lines[1]:find('2026', 1, true) - 1, 'comment'))
assert(has_capture(0, lines[1]:find('due:', 1, true) - 1, 'comment'))
assert(has_capture(4, 0, 'markup.strikethrough'))
assert(has_capture(4, #lines[5] - 1, 'markup.strikethrough'))
assert(not has_capture(0, 0, 'markup.strikethrough'))
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), lines))
local namespace = vim.api.nvim_get_namespaces().todotxt_checkboxes
local function checkboxes()
  return vim.api.nvim_buf_get_extmarks(0, namespace, 0, -1, { details = true })
end
vim.api.nvim_exec_autocmds('TextChanged', { buffer = 0 })
assert(#checkboxes() == 5, 'Blank lines must not have checkboxes')
assert(checkboxes()[1][4].virt_text[1][1] == '☐ ')
assert(checkboxes()[5][4].virt_text[1][1] == '☑ ')
assert(checkboxes()[1][4].virt_text_pos == 'inline')
local toggle = vim.fn.maparg('<leader>td', 'n', false, true)
assert(toggle.buffer == 1 and type(toggle.callback) == 'function')
vim.api.nvim_win_set_cursor(0, { 2, 0 })
toggle.callback()
assert(
  vim.api.nvim_get_current_line():match('^x %(B%) %d%d%d%d%-%d%d%-%d%d Next task$'),
  vim.api.nvim_get_current_line()
)
assert(checkboxes()[2][4].virt_text[1][1] == '☑ ')
assert(has_capture(1, 0, 'markup.strikethrough'))
toggle.callback()
assert(vim.api.nvim_get_current_line() == lines[2])
assert(checkboxes()[2][4].virt_text[1][1] == '☐ ')
assert(not has_capture(1, 0, 'markup.strikethrough'))
vim.api.nvim_win_set_cursor(0, { 1, 0 })
toggle.callback()
assert(require('todotxt.task').is_completed(vim.api.nvim_get_current_line()))
toggle.callback()
assert(vim.api.nvim_get_current_line() == lines[1], 'Toggling must preserve dates, priority and tags')
vim.api.nvim_win_set_cursor(0, { 6, 0 })
toggle.callback()
assert(vim.api.nvim_get_current_line() == '')
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), lines))
vim.api.nvim_exec_autocmds('BufEnter', { buffer = 0 })
assert(#checkboxes() == 5, 'Re-entering a buffer must not duplicate checkboxes')
vim.cmd('enew!')
vim.bo.filetype = 'text'
vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'Ordinary text' })
vim.api.nvim_exec_autocmds('TextChanged', { buffer = 0 })
assert(#checkboxes() == 0)
assert(vim.fn.maparg('<leader>td', 'n') == '')
vim.fn.delete(home, 'rf')
print('todo.txt LSP, highlighting and completion checkboxes: OK')
