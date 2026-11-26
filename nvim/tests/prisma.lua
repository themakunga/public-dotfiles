-- Run from nvim/ with Prisma's Tree-sitter parser and Mason server installed:
-- nvim --headless -u NONE -i NONE -l tests/prisma.lua
vim.cmd.packloadall()
vim.cmd.packadd('nvim-lspconfig')
vim.cmd.packadd('nvim-treesitter')
vim.env.PATH = vim.fn.stdpath('data') .. '/mason/bin:' .. vim.env.PATH
vim.opt.runtimepath:prepend(vim.fn.getcwd())
_G.CMD = require('core.cmd')
require('plugins.nvim-treesitter.features').setup()
local root = vim.fn.tempname()
vim.fn.mkdir(root .. '/.git', 'p')
vim.fn.writefile({ '{}' }, root .. '/package.json')
local schema = { 'model User {', '  id Int @id', '  name String', '}' }
vim.fn.writefile(schema, root .. '/schema.prisma')
vim.lsp.enable('prismals')
vim.cmd.edit(root .. '/schema.prisma')
vim.bo.filetype = assert(vim.filetype.match({ filename = root .. '/schema.prisma' }))
assert(vim.bo.filetype == 'prisma')
local parser = vim.treesitter.get_parser(0, 'prisma')
local tree = parser:parse()[1]
assert(not tree:root():has_error(), 'Valid Prisma schema failed to parse')
assert(vim.treesitter.query.get('prisma', 'highlights'), 'Missing Prisma highlight queries')
assert(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()], 'Prisma highlighting did not start')
vim.api.nvim_buf_set_lines(0, 2, 3, false, { '  name MissingType' })
assert(
  vim.wait(10000, function()
    return vim.iter(vim.diagnostic.get(0)):any(function(diagnostic)
      return diagnostic.message:find('MissingType', 1, true) ~= nil
    end)
  end),
  'Prisma LSP did not diagnose the invalid field type'
)
local clients = vim.lsp.get_clients({ bufnr = 0, name = 'prismals' })
assert(#clients == 1, 'Expected one attached Prisma client')
clients[1]:stop(true)
vim.cmd('bwipeout!')
vim.fn.delete(root, 'rf')
print('Prisma filetype, real parser/highlighting and LSP diagnostics: OK')
