-- Run: nvim --headless -u NONE -i NONE -l tests/obsidian-frontmatter.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:prepend(vim.fn.stdpath('data') .. '/site/pack/core/opt/obsidian.nvim')

local obsidian = require('obsidian')
local setup, pack_add = obsidian.setup, vim.pack.add
local checker = _G.Checker
local opts
obsidian.setup = function(config)
  opts = config
end
vim.pack.add = function() end
_G.Checker = {
  check = function()
    return true
  end,
}
require('plugins.obsidian-nvim').plugin()
obsidian.setup, vim.pack.add, _G.Checker = setup, pack_add, checker

local vault = vim.fn.tempname()
vim.fn.mkdir(vault, 'p')
opts.workspaces = { { name = 'test', path = vault } }
opts.picker.name = nil
opts.footer = { enabled = false }
setup(opts)
assert(not Obsidian._config_error, Obsidian._config_error)
require('obsidian.lsp').start = function() end
vim.cmd('filetype on')

local date = os.date
local now = '2026-11-05T12:00:00-0300'
os.date = function(format, ...)
  if format == '%Y-%m-%dT%H:%M:%S%z' then
    return now
  end
  return date(format, ...)
end
local ok, err = pcall(function()
  vim.cmd.edit(vim.fn.fnameescape(vault .. '/note.md'))
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { '# Test', '', 'Original content.' })
  vim.cmd.write()
  local note = obsidian.Note.from_file(vault .. '/note.md')
  assert(note.metadata.created_at == now, 'Set created_at on first save')
  assert(note.metadata.updated_at == now, 'Set updated_at on first save')
  assert(note.metadata.draft == false, 'Default draft to boolean false')

  local created_at = note.metadata.created_at
  note:add_field('draft', true)
  note:add_field('custom', 'preserved')
  note:add_alias('Test alias')
  note:add_tag('test')
  note:update_frontmatter(0)
  now = '2026-11-05T12:01:00-0300'
  vim.api.nvim_buf_set_lines(0, -1, -1, false, { 'Edited content.' })
  vim.cmd.write()
  note = obsidian.Note.from_file(vault .. '/note.md')
  assert(note.metadata.created_at == created_at, 'Preserve created_at on later saves')
  assert(note.metadata.updated_at == now, 'Refresh updated_at in the saved file')
  assert(note.metadata.draft == true, 'Preserve an explicit draft value')
  assert(note.metadata.custom == 'preserved', 'Preserve custom metadata')
  assert(vim.tbl_contains(note.aliases, 'Test alias'), 'Preserve aliases')
  assert(vim.tbl_contains(note.tags, 'test'), 'Preserve tags')
  local lines = vim.fn.readfile(vault .. '/note.md')
  assert(lines[#lines] == 'Edited content.', 'Preserve content')

  vim.cmd.edit(vim.fn.fnameescape(vault .. '/existing.md'))
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { '---', 'created_at: 2020-01-01', 'draft: false', '---', '# Existing' })
  vim.cmd.write()
  note = obsidian.Note.from_file(vault .. '/existing.md')
  assert(note.metadata.created_at == '2020-01-01', 'Preserve existing creation dates')
  assert(note.metadata.draft == false, 'Preserve explicit false')
  assert(note.metadata.updated_at == now, 'Backfill missing updated_at')

  for index, path in ipairs({
    vault .. '/README.md',
    vault .. '/CONTRIBUTING.md',
    vault .. '/CHANGELOG.md',
    vault .. '-outside.markdown',
  }) do
    vim.cmd.edit(vim.fn.fnameescape(path))
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { '# Markdown', '', 'Preserved content.' })
    vim.cmd.write()
    note = obsidian.Note.from_file(path)
    assert(note.metadata.updated_at == now, 'Update every Markdown file: ' .. path)
    assert(note.metadata.created_at == now, 'Initialize creation time: ' .. path)
    assert(note.metadata.draft == false, 'Initialize draft: ' .. path)
    local created = note.metadata.created_at
    now = '2026-11-05T12:02:0' .. index .. '-0300'
    vim.api.nvim_buf_set_lines(0, -1, -1, false, { 'Another edit.' })
    vim.cmd.write()
    note = obsidian.Note.from_file(path)
    assert(note.metadata.updated_at == now, 'Refresh timestamps on later saves: ' .. path)
    assert(note.metadata.created_at == created, 'Preserve creation time: ' .. path)
  end

  local unclosed = { '---', 'updated_at: old', '# No closing delimiter' }
  vim.cmd.edit(vim.fn.fnameescape(vault .. '-outside.md'))
  vim.api.nvim_buf_set_lines(0, 0, -1, false, unclosed)
  vim.cmd.write()
  assert(vim.deep_equal(vim.fn.readfile(vault .. '-outside.md'), unclosed), 'Preserve unclosed frontmatter')
end)
os.date = date
vim.cmd('bwipeout!')
vim.fn.delete(vault, 'rf')
vim.fn.delete(vault .. '-outside.md')
vim.fn.delete(vault .. '-outside.markdown')
assert(ok, err)
print('Obsidian frontmatter on save: OK')
