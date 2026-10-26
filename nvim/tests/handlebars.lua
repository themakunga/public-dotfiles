-- Run: nvim --headless -u NONE -i NONE -l tests/handlebars.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
require('plugins.nvim-treesitter.filetypes').setup()

for extension, filetype in pairs({
  ['markdown.hbs'] = 'markdown',
  ['md.hbs'] = 'markdown',
  ['yaml.hbs'] = 'yaml',
  ['yml.hbs'] = 'yaml',
  ['toml.hbs'] = 'toml',
  markdown = 'markdown',
  yaml = 'yaml',
  toml = 'toml',
  hbs = 'handlebars',
}) do
  local filename = '/tmp/templates/example.' .. extension
  assert(vim.filetype.match({ filename = filename }) == filetype, filename)
  if extension ~= 'hbs' then
    assert(vim.treesitter.language.get_lang(filetype) == filetype, filetype)
  end
end

print('Handlebars template filetypes: OK')
