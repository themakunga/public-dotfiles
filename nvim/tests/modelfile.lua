-- Run from nvim/: nvim --headless -u NONE -i NONE -l tests/modelfile.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:append(vim.fn.getcwd() .. '/after')
require('plugins.nvim-treesitter.filetypes').setup()
vim.cmd('filetype on')
vim.cmd('syntax on')

for _, filename in ipairs({
  'Modelfile',
  'modelfile',
  '.Modelfile',
  'GLaDOS.Modelfile',
  'example.modelfile',
  'Modelfile.example',
}) do
  assert(vim.filetype.match({ filename = filename }) == 'modelfile', filename)
end
assert(vim.filetype.match({ filename = 'Dockerfile' }) == 'dockerfile')
assert(vim.filetype.match({ filename = 'Containerfile' }) == 'dockerfile')
for _, name in ipairs({ 'SKILL', 'SKILL.md', 'AGENT', 'AGENT.md', 'AGENTS', 'AGENTS.md', 'CLAUDE.md', 'rules.mdc' }) do
  assert(vim.filetype.match({ filename = name }) == 'markdown', name)
end
assert(not vim.tbl_contains(dofile('lsp/dockerls.lua').filetypes, 'modelfile'))

vim.cmd.edit(vim.fn.getcwd() .. '/example.Modelfile')
vim.api.nvim_buf_set_lines(0, 0, -1, false, {
  'FROM llama3.2',
  'PARAMETER temperature 0.7',
  'SYSTEM """',
  'MESSAGE is prompt text, not an instruction.',
  '{{ .Prompt }}',
  '"""',
  'MESSAGE user "Hello"',
  '# A comment',
  'LICENSE """MIT"""',
})
assert(vim.bo.filetype == 'modelfile')
for _, check in ipairs({
  { 1, 1, 'modelfileInstruction' },
  { 2, 11, 'modelfileParameter' },
  { 3, 1, 'modelfileInstruction' },
  { 4, 1, 'modelfileMultiline' },
  { 5, 1, 'modelfileTemplate' },
  { 7, 9, 'modelfileRole' },
  { 8, 1, 'modelfileComment' },
  { 9, 1, 'modelfileInstruction' },
}) do
  assert(vim.fn.synIDattr(vim.fn.synID(check[1], check[2], 1), 'name') == check[3], vim.inspect(check))
end
print('Ollama syntax, filename detection and agent Markdown filetypes: OK')
