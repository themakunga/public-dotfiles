-- Run: nvim --headless -u NONE -i NONE -l ~/.public-dotfiles/nvim/tests/codex.lua
vim.opt.runtimepath:prepend(vim.fn.expand('~/.config/nvim'))
vim.g.mapleader = ' '
_G.Log = { error = function(msg) error(msg) end }
_G.KM = require('core.keymapping')
_G.CMD = require('core.cmd')
-- Exercise the terminal lifecycle without submitting a prompt to Codex.
local jobstart = vim.fn.jobstart
vim.fn.jobstart = function(cmd, opts)
  assert(vim.deep_equal(cmd, { 'codex' }) and opts.term)
  return jobstart({ 'cat' }, opts)
end
require('core.loader')('plugins.codex')
assert(vim.fn.exists(':Codex') == 2)
assert(type(vim.fn.maparg('<leader>cc', 'n', false, true).callback) == 'function')
vim.cmd.Codex()
local buf = vim.api.nvim_get_current_buf()
local job = vim.b.terminal_job_id
assert(vim.bo.buftype == 'terminal' and job > 0)
assert(vim.fn.maparg('<C-g>', 't'):find('Codex', 1, true))
vim.cmd.Codex()
assert(#vim.fn.win_findbuf(buf) == 0)
assert(vim.fn.jobwait({ job }, 0)[1] == -1)
vim.cmd.Codex()
assert(vim.api.nvim_get_current_buf() == buf and vim.b.terminal_job_id == job)
vim.fn.jobstop(job)
assert(vim.wait(3000, function() return #vim.fn.win_findbuf(buf) == 0 end))
vim.cmd.Codex()
assert(vim.api.nvim_get_current_buf() ~= buf)
vim.fn.jobstop(vim.b.terminal_job_id)
vim.fn.jobstart = jobstart
print('Codex terminal: load, open, hide, reuse and restart OK')
