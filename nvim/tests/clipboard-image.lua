-- Run: nvim --headless -u NONE -i NONE -l nvim/tests/clipboard-image.lua /path/to/clipboard-image.nvim
vim.opt.runtimepath:prepend(vim.fn.expand('~/.public-dotfiles/nvim'))
vim.opt.runtimepath:append(assert(arg[1], 'Pass the upstream plugin runtime path'))
_G.Log = {
  warn = function(message)
    error(message)
  end,
}
_G.Checker = require('core.checker')

local root = vim.fn.tempname()
vim.fn.mkdir(root .. '/bin', 'p')
root = assert(vim.uv.fs_realpath(root))
local image =
  vim.base64.decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aSfkAAAAASUVORK5CYII=')
local file = assert(io.open(root .. '/pixel.png', 'wb'))
file:write(image)
file:close()
vim.env.CLIPBOARD_IMAGE_FIXTURE = root .. '/pixel.png'
vim.env.PATH = root .. '/bin:' .. vim.env.PATH
vim.fn.writefile({
  '#!/bin/sh',
  'if [ "$1" = "-b" ]; then',
  '  printf "%s\\n" iVBORw0KGgo=',
  'else',
  '  cp "$CLIPBOARD_IMAGE_FIXTURE" "$1"',
  'fi',
}, root .. '/bin/pngpaste')
vim.fn.setfperm(root .. '/bin/pngpaste', 'rwx------')

local pack_add = vim.pack.add
vim.pack.add = function(specs)
  assert(specs[1].src == 'https://github.com/ekickx/clipboard-image.nvim')
  vim.cmd('runtime plugin/clipboard-image.vim')
end
require('plugins.clipboard-image').plugin()
vim.pack.add = pack_add
assert(vim.fn.exists(':PasteImg') == 2)
assert(type(require('clipboard-image.paste').paste_img) == 'function')
assert(require('clipboard-image.health').check_current_dep())

vim.cmd.cd(root)
vim.bo.filetype = 'markdown'
vim.cmd.PasteImg()
local path = assert(vim.api.nvim_get_current_line():match('^!%[%]%((img/[%d%-]+%.png)%)$'))
local pasted = assert(io.open(root .. '/' .. path, 'rb'))
assert(pasted:read('*a') == image)
pasted:close()

local first_vault = root .. '/first vault'
local second_vault = root .. '/second vault'
local nested_vault = first_vault .. '/nested vault'
for _, vault in ipairs({ first_vault, second_vault, nested_vault }) do
  vim.fn.mkdir(vault .. '/.obsidian', 'p')
  vim.fn.mkdir(vault .. '/notes/deep', 'p')
end
local cases = {
  { note = first_vault .. '/note.md', vault = first_vault, link = 'assets/' },
  { note = first_vault .. '/notes/deep/note.md', vault = first_vault, link = '../../assets/' },
  { note = second_vault .. '/notes/deep/note.md', vault = second_vault, link = '../../assets/' },
  { note = nested_vault .. '/note.md', vault = nested_vault, link = 'assets/' },
}
for index, case in ipairs(cases) do
  local buffer = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(buffer)
  vim.api.nvim_buf_set_name(buffer, case.note)
  vim.bo.filetype = 'markdown'
  local name = 'vault-' .. index .. '.png'
  require('clipboard-image.config').config.default.img_name = 'vault-' .. index
  vim.cmd.PasteImg()
  assert(vim.api.nvim_get_current_line() == '![](' .. case.link .. name .. ')')
  local saved = assert(io.open(case.vault .. '/assets/' .. name, 'rb'))
  assert(saved:read('*a') == image)
  saved:close()
  assert(vim.fn.isdirectory(vim.fs.dirname(case.note) .. '/img') == 0)
end
assert(vim.fn.isdirectory(root .. '/assets') == 0, 'Vault assets must not follow the working directory')

vim.cmd('checkhealth clipboard-image')
local report = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
assert(report:find('pngpaste is installed', 1, true), report)
assert(not report:find('ERROR', 1, true), report)
print('Clipboard image: vault assets, nested-note links, vault switching, fallback and health OK')
