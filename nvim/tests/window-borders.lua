-- Run from nvim/: nvim --headless -u NONE -i NONE -l tests/window-borders.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
for _, plugin in ipairs({ 'tokyonight.nvim', 'bufferline.nvim', 'nvim-web-devicons' }) do
  vim.cmd.packadd(plugin)
end
if vim.env.NVIM_WINSEP_PATH then
  vim.opt.rtp:prepend(vim.env.NVIM_WINSEP_PATH)
else
  vim.cmd.packadd('colorful-winsep.nvim')
end

_G.Checker = require('core.checker')
_G.CMD = require('core.cmd')
_G.KM = require('core.keymapping')
local pack_add = vim.pack.add
vim.pack.add = function() end
require('settings.options').load()
require('plugins.colorscheme').plugin()
require('plugins.bufferline').plugin()
require('plugins.window-borders').plugin()
vim.pack.add = pack_add
vim.wait(50)
vim.o.laststatus = 3
vim.o.columns = 120
vim.o.lines = 40

local function buffer(name)
  vim.cmd.enew()
  vim.api.nvim_buf_set_name(0, name)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'First line', 'Last line' })
  vim.bo.modified = false
  return vim.api.nvim_get_current_buf()
end

local initial = vim.api.nvim_get_current_buf()
local first = buffer('/tmp/rounded-first.lua')
if initial ~= first then
  vim.api.nvim_buf_delete(initial, { force = true })
end
vim.cmd.vsplit()
local second = buffer('/tmp/rounded-second.lua')
vim.cmd.split()
local third = buffer('/tmp/rounded-third.lua')
local view = require('colorful-winsep.view')
local function check_separators()
  local layout = vim.fn.winlayout()
  local sizes = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == '' then
      sizes[win] = { vim.api.nvim_win_get_width(win), vim.api.nvim_win_get_height(win) }
    end
  end
  view.render()
  assert(vim.deep_equal(layout, vim.fn.winlayout()), 'Borders must preserve the split layout')
  local shown = 0
  for _, sep in pairs(view.separators) do
    if sep._show then
      shown = shown + 1
      local cfg = vim.api.nvim_win_get_config(sep.winid)
      assert(cfg.width == 1 or cfg.height == 1, 'Separators must occupy one cell')
      assert(cfg.focusable == false, 'Borders must not capture navigation')
    end
  end
  for win, size in pairs(sizes) do
    assert(vim.api.nvim_win_get_width(win) == size[1] and vim.api.nvim_win_get_height(win) == size[2])
  end
  assert(shown > 0, 'Split separators must be visible')
end

check_separators()
local has_corner = false
for _, node in ipairs(view.border_model:get_nodes()) do
  has_corner = has_corner or vim.tbl_contains({ '╭', '╮', '╰', '╯' }, node.char)
end
assert(has_corner, 'Intersecting splits must have rounded corners')
vim.cmd.wincmd('h')
check_separators()
vim.o.columns = 100
vim.cmd('wincmd =')
check_separators()
vim.cmd.wincmd('l')
check_separators()

local tabline = vim.o.tabline
local rendered = vim.api.nvim_eval_statusline(tabline, { use_tabline = true, maxwidth = 100 }).str
for _, name in ipairs({ 'rounded-first', 'rounded-second', 'rounded-third' }) do
  assert(rendered:find(name, 1, true), 'Every buffer must remain visible')
end
assert(select(2, rendered:gsub('', '')) == 3 and select(2, rendered:gsub('', '')) == 3)
local colors = require('tokyonight.colors').setup()
assert(vim.api.nvim_get_hl(0, { name = 'BufferLineBufferSelected' }).bg == tonumber(colors.blue:sub(2), 16))
vim.cmd.colorscheme('tokyonight')
assert(vim.api.nvim_get_hl(0, { name = 'ColorfulWinSep' }).fg == tonumber(colors.blue:sub(2), 16))

vim.cmd.only()
view.render()
for _, sep in pairs(view.separators) do
  assert(not sep._show, 'Closing splits must remove their borders')
end
for _, buf in ipairs({ first, second, third }) do
  assert(vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 0, -1, false), { 'First line', 'Last line' }))
end
print('Rounded buffer tabs and compact split borders: OK')
