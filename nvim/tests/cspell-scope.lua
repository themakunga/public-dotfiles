-- Run from nvim/ with nvim-lspconfig installed and cspell-language-server on PATH:
-- nvim --headless -u NONE -i NONE -l tests/cspell-scope.lua
vim.cmd.packadd('nvim-lspconfig')
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:append(vim.fn.getcwd() .. '/after')
local config = vim.lsp.config.cspell_ls
assert(config.cmd[1] == 'cspell-language-server', 'Plugin defaults replaced the official CSpell server')
local root = vim.fn.tempname()
vim.fn.mkdir(root, 'p')
root = assert(vim.uv.fs_realpath(root))
for _, path in ipairs({
  'configured/.git',
  'configured/src/ignored',
  'configured/docs',
  'configured/nested/.git',
  'unconfigured/.git',
}) do
  vim.fn.mkdir(root .. '/' .. path, 'p')
end
vim.fn.writefile({
  'version: "0.2"',
  'files: [src/**]',
  'ignorePaths: [src/ignored/**]',
  'words: [Sprocketwobble]',
}, root .. '/configured/.cspell.config.yaml')
local reports = {}
local publish = vim.lsp.handlers['textDocument/publishDiagnostics']
vim.lsp.handlers['textDocument/publishDiagnostics'] = function(err, result, ctx, options)
  reports[result.uri] = result.diagnostics
  return publish(err, result, ctx, options)
end
vim.lsp.enable('cspell_ls')
local function open(path, filetype)
  vim.fn.writefile({ 'Sprocketwobble wrod' }, root .. '/' .. path)
  vim.cmd.edit(root .. '/' .. path)
  vim.bo.filetype = filetype
  return vim.api.nvim_get_current_buf()
end
for _, filetype in ipairs({ 'markdown', 'lua', 'vue', 'unlisted-language', '' }) do
  local buf = open('configured/src/note-' .. (filetype ~= '' and filetype or 'plain'), filetype)
  if filetype == '' then
    vim.api.nvim_exec_autocmds('FileType', { buffer = buf })
  end
  assert(
    vim.wait(10000, function()
      local diagnostics = vim.diagnostic.get(buf)
      return #diagnostics == 1 and diagnostics[1].message:find('wrod', 1, true)
    end),
    'Missing configured diagnostics for ' .. filetype
  )
end
for _, path in ipairs({ 'configured/src/ignored/note.md', 'configured/docs/note.md' }) do
  local buf = open(path, 'markdown')
  local uri = vim.uri_from_bufnr(buf)
  assert(
    vim.wait(5000, function()
      return reports[uri] ~= nil
    end),
    'Missing exclusion response: ' .. path
  )
  assert(#reports[uri] == 0, 'CSpell checked an excluded file: ' .. path)
end
for _, path in ipairs({ 'unconfigured/note.md', 'configured/nested/note.md' }) do
  local buf = open(path, 'markdown')
  assert(vim.wait(100, function()
    return false
  end) == false)
  assert(#vim.lsp.get_clients({ bufnr = buf, name = 'cspell_ls' }) == 0, path)
end
for _, client in ipairs(vim.lsp.get_clients()) do
  client:stop(true)
end
vim.lsp.handlers['textDocument/publishDiagnostics'] = publish
vim.cmd('bwipeout!')
vim.fn.delete(root, 'rf')
print('CSpell effective server, all filetypes, project boundaries and exclusions: OK')
