-- Run: nvim --headless -u NONE -i NONE -l nvim/tests/trouble-code-action.lua [nvim-config-root]
local config_root = arg[1] or vim.fn.expand('~/.public-dotfiles/nvim')
vim.opt.runtimepath:prepend(config_root)
vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/site/pack/core/opt/trouble.nvim')
vim.g.mapleader = ' '
vim.pack.add = function() end
_G.Checker = {
  check = function()
    return true
  end,
}
_G.KM = { bulk_map = function() end }
require('plugins.trouble').plugin()
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)

local root = vim.fn.tempname()
vim.fn.mkdir(root, 'p')
vim.fn.writefile({ 'dictionaries = ["en_us"]' }, root .. '/.codebook.toml')
vim.cmd.edit(root .. '/note.md')
vim.bo.filetype = 'markdown'
vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'A wrod in this sentence.' })
local source = vim.api.nvim_get_current_buf()
local config = dofile(config_root .. '/lsp/codebook.lua')
config.name, config.root_dir = 'codebook', root
local client = assert(vim.lsp.start(config))
assert(
  vim.wait(10000, function()
    return #vim.diagnostic.get(source) > 0
  end),
  'Codebook did not publish diagnostics'
)
assert(vim.lsp.get_client_by_id(client):supports_method('textDocument/codeAction'))
local other = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(other)
vim.api.nvim_buf_set_lines(other, 0, -1, false, { 'Keep this text intact.' })
local trouble = require('trouble')
local view = trouble.open({ mode = 'diagnostics', focus = true, auto_preview = false, filter = { buf = source } })
assert(vim.wait(3000, function()
  return view:is_open() and view:count() > 0
end))
local rendered = false
view:wait(function()
  rendered = true
end)
assert(
  vim.wait(3000, function()
    return rendered
  end),
  'Trouble did not render'
)
view.win:focus()
view:move({ idx = 1 })
assert(view:at().item, 'Select an actual diagnostic')
local trouble_buffer = vim.api.nvim_get_current_buf()
assert(vim.bo.filetype == 'trouble')
local notifications = {}
vim.notify = function(message)
  notifications[#notifications + 1] = message
end
local selected = false
vim.ui.select = function(actions, opts, callback)
  selected = true
  assert(vim.api.nvim_get_current_buf() == trouble_buffer, 'Keep focus in Trouble while choosing a fix')
  assert(view:is_open(), 'Keep the Trouble panel open')
  for _, action in ipairs(actions) do
    if opts.format_item(action):lower():find('word', 1, true) then
      callback(action)
      return
    end
  end
  error('Missing expected spelling correction: ' .. vim.inspect(actions))
end
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Space>ca', true, false, true), 'xt', false)
assert(
  vim.wait(5000, function()
    return selected or #notifications > 0
  end),
  'No action response'
)
assert(selected, table.concat(notifications, '\n'))
assert(
  vim.wait(3000, function()
    return vim.api.nvim_buf_get_lines(source, 0, 1, false)[1] == 'A word in this sentence.'
  end),
  'Correction must update the source document'
)
assert(view:is_open(), 'Correction must not close Trouble')
assert(vim.api.nvim_get_current_buf() == trouble_buffer, 'Correction must retain Trouble focus')
assert(vim.api.nvim_buf_get_lines(other, 0, 1, false)[1] == 'Keep this text intact.')
vim.lsp.get_client_by_id(client):stop(true)
vim.fn.delete(root, 'rf')
print('Trouble Codebook action: source correction and panel focus OK')
