-- Run: nvim --headless -u NONE -i NONE -l ~/.public-dotfiles/nvim/tests/obsidian-frontmatter.lua
vim.opt.runtimepath:prepend(vim.fn.expand('~/.public-dotfiles/nvim'))
vim.o.conceallevel = 2
vim.cmd.packadd('obsidian.nvim')
local obsidian = require('obsidian')
local opts
local setup, pack_add = obsidian.setup, vim.pack.add
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
obsidian.setup, vim.pack.add = setup, pack_add

local root = vim.fn.tempname()
vim.fn.mkdir(root .. '/posts/2026', 'p')
root = assert(vim.uv.fs_realpath(root))
local content = '/Users/nicolas/Projects/Personal/personal-content'
vim.fn.mkdir(root .. '/.utils', 'p')
vim.fn.mkdir(root .. '/.templates', 'p')
vim.fn.writefile(
  vim.fn.readfile(content .. '/.utils/frontmatter.schema.json'),
  root .. '/.utils/frontmatter.schema.json'
)
vim.fn.writefile(
  vim.fn.readfile(content .. '/.templates/article.template.md'),
  root .. '/.templates/article.template.md'
)
opts.workspaces = { { name = 'site-content', path = root, overrides = opts.workspaces[3].overrides } }
obsidian.setup(opts)
assert(not Obsidian._config_error, Obsidian._config_error)

local Note = require('obsidian.note')
local Path = require('obsidian.path')
local note = Note.new('article', {}, { 'test' }, Path.new(root .. '/posts/2026/article.md'), 'Article')
note:write()
local created = Note.from_file(note.path)
assert(created.metadata.created_at:match('^%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d:%d%d[%+%-]%d%d%d%d$'))
assert(created.metadata.updated_at == created.metadata.created_at)
assert(created.metadata.date == nil and created.metadata.audio == 'es-CL')
assert(created.metadata.draft == false and created.metadata.category == '')
assert(created.metadata.comments.show == false and created.metadata.comments.enable == false)
local schema = vim.json.decode(table.concat(vim.fn.readfile(root .. '/.utils/frontmatter.schema.json'), '\n'))
schema.properties.comments.default.show = true
vim.fn.writefile({ vim.json.encode(schema) }, root .. '/.utils/frontmatter.schema.json')
local templated = Note.create({
  id = 'templated',
  dir = root .. '/posts/2026',
  title = 'Article: "Quoted"',
  template = 'article.template.md',
})
templated = templated:write()
assert(templated.metadata.date == nil)
assert(templated.metadata.description == '' and templated.metadata.image == '')
assert(templated.metadata.type == 'article')
assert(templated.metadata.created_at:match('^%d%d%d%d%-%d%d%-%d%dT'))
assert(templated.metadata.comments.show == false)
local plain = Note.new('defaults', {}, {}, Path.new(root .. '/posts/2026/defaults.md'), 'Defaults'):write()
plain = Note.from_file(plain.path)
assert(plain.metadata.comments.show == true, 'New notes must use the current schema defaults')
assert(plain.metadata.comments.enable == false)
assert(not table.concat(vim.fn.readfile(tostring(templated.path)), '\n'):find('{{', 1, true))

vim.cmd('filetype plugin on')
vim.cmd.edit(tostring(note.path))
vim.api.nvim_exec_autocmds('BufEnter', { buffer = 0 })
local date = os.date
os.date = function()
  return '2099-01-02T03:04:05-0300'
end
vim.api.nvim_buf_set_lines(0, -1, -1, false, { 'Updated content.' })
vim.cmd.write()
os.date = date
local saved = Note.from_file(note.path)
assert(saved.metadata.created_at == created.metadata.created_at)
assert(saved.metadata.updated_at == '2099-01-02T03:04:05-0300')
assert(saved.metadata.date == nil and saved.metadata.audio == 'es-CL')
assert(saved.metadata.draft == false and saved.metadata.category == '')
assert(saved.tags[1] == 'test')
local lines = vim.fn.readfile(tostring(note.path))
assert(lines[#lines] == 'Updated content.')

local frontmatter = Obsidian.opts.frontmatter.func
note.metadata = {
  created_at = created.metadata.created_at,
  date = '2020-01-01',
  audio = 'en-US',
  draft = true,
  category = 'Existing',
  custom = 'Keep',
  comments = { show = true, enable = false },
}
local existing = frontmatter(note)
assert(existing.created_at == created.metadata.created_at)
assert(existing.comments.show == true and existing.comments.enable == false)
assert(existing.date == '2020-01-01' and existing.audio == 'en-US')
assert(existing.draft == true and existing.category == 'Existing' and existing.custom == 'Keep')
for _, value in ipairs({ vim.NIL, '' }) do
  note.metadata = { created_at = value, date = value, audio = value, draft = vim.NIL }
  local empty = frontmatter(note)
  assert(type(empty.created_at) == 'string' and empty.created_at ~= '')
  assert(empty.date == value and empty.audio == 'es-CL')
  assert(empty.draft == false)
end
for _, path in ipairs({ 'README.md', 'portfolio/project.md', '.templates/article.template.md', 'posts-archive/old.md' }) do
  note.path = Path.new(root .. '/' .. path)
  note.metadata = { custom = 'Keep' }
  local other = frontmatter(note)
  assert(other.created_at == nil and other.updated_at == nil and other.draft == nil and other.category == nil)
  assert(other.date == nil and other.audio == nil)
  assert(other.custom == 'Keep')
end
vim.cmd('bdelete!')
print('Obsidian frontmatter: creation, save, defaults, metadata preservation and post scope OK')
