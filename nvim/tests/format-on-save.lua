-- Run from a project with Prettier: nvim --headless -u NONE -i NONE -l ~/.public-dotfiles/nvim/tests/format-on-save.lua
vim.opt.runtimepath:prepend(vim.fn.stdpath('data') .. '/site/pack/core/opt/conform.nvim')
local original_add, original_checker, original_cmd = vim.pack.add, _G.Checker, _G.CMD
vim.pack.add = function() end
_G.Checker = {
  check = function()
    return true
  end,
}
_G.CMD = { usrcmd = function() end }
dofile(vim.fn.stdpath('config') .. '/lua/plugins/conform.lua').plugin()
vim.pack.add, _G.Checker, _G.CMD = original_add, original_checker, original_cmd

local filename = vim.fn.getcwd() .. '/.format-on-save-test.json'
assert(vim.fn.filereadable(filename) == 0, 'Test file already exists')
local ok, err = pcall(function()
  vim.cmd.edit(vim.fn.fnameescape(filename))
  vim.bo.filetype = 'json'
  local original = '{"journal":true}'
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { original })
  vim.cmd.write()
  local formatted = table.concat(vim.fn.readfile(filename), '\n')
  assert(formatted ~= original, 'JSON must be formatted before write returns')
  assert(vim.json.decode(formatted).journal == true, 'Formatting must preserve data')
  vim.cmd.write()
  assert(table.concat(vim.fn.readfile(filename), '\n') == formatted, 'Formatting must be idempotent')
  vim.b.disable_autoformat = true
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { original })
  vim.cmd.write()
  assert(table.concat(vim.fn.readfile(filename), '\n') == original, 'Buffer opt-out must remain supported')
end)
vim.cmd('bwipeout!')
vim.fn.delete(filename)
assert(ok, err)
print('Format on save: OK')
