-- Run from the repo: nvim --headless -u NONE -i NONE -l tests/argo.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:append(vim.fn.getcwd() .. '/after')
-- Use installed parsers without loading the user's plugins or triggering updates.
for _, path in ipairs(vim.fn.glob(vim.fn.stdpath('data') .. '/site/pack/*/opt/nvim-treesitter', false, true)) do
  vim.opt.runtimepath:append(path)
  vim.opt.runtimepath:append(path .. '/runtime')
end
require('plugins.nvim-treesitter.argo').setup()

local cases = {
  { 'python3', 'python', 'print(42)' },
  { '/usr/bin/python3.12', 'python', 'print(42)' },
  { 'java', 'java', 'class Main {}' },
  { 'sh', 'bash', 'echo hello' },
  { '/bin/bash', 'bash', 'echo hello' },
  { 'lua', 'lua', 'print(42)' },
  { 'go', 'go', 'package main' },
  { 'node', 'javascript', 'console.log(42)' },
}
for _, case in ipairs(cases) do
  for _, command in ipairs({ 'command: ["' .. case[1] .. '"]', 'command:\n    - \'' .. case[1] .. '\'' }) do
    for _, body in ipairs({ 'source: |-\n    ', 'args:\n    - |+\n      ' }) do
      for _, reverse in ipairs({ false, true }) do
        local code = body .. case[3] .. '\n'
        local yaml = 'script:\n  ' .. (reverse and (code .. '  ' .. command .. '\n') or (command .. '\n  ' .. code))
        local parser = vim.treesitter.get_string_parser(yaml, 'yaml')
        parser:parse(true)
        assert(parser:children()[case[2]], case[1] .. ': missing injection\n' .. yaml)
        local child = parser:children()[case[2]]
        local trees = child:parse(true)
        assert(not trees[1]:root():has_error(), case[1] .. ': invalid injected code')
      end
    end
  end
end
for _, yaml in ipairs({
  'source: |\n  print(42)\n',
  'script:\n  command: []\n  source: |\n    print(42)\n',
  'script:\n  command: [unknown]\n  source: |\n    print(42)\n',
  'script:\n  command: [""]\n  source: |\n    print(42)\n',
  'script:\n  command:\n    -\n  source: |\n    print(42)\n',
  'script:\n  command: [python]\n  source: >\n    print(42)\n',
  'config:\n  command: [python]\n  source: |\n    print(42)\n',
}) do
  local parser = vim.treesitter.get_string_parser(yaml, 'yaml')
  parser:parse(true)
  assert(vim.tbl_isempty(parser:children()), 'Unexpected injection: ' .. yaml)
end
local container = vim.treesitter.get_string_parser(
  'container:\n  command: [node, -e]\n  args:\n    - |\n      console.log(42)\n',
  'yaml'
)
container:parse(true)
assert(container:children().javascript, 'Missing container args injection')
print('Argo injections: OK')
