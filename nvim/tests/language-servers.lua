-- Run from nvim/ with the declared servers on PATH:
-- nvim --headless -u NONE -i NONE -l tests/language-servers.lua
local root = vim.fn.tempname()
vim.fn.mkdir(root, 'p')
root = assert(vim.uv.fs_realpath(root))
local formats = {
  { 'cspell.json', '{"version":"0.2","words":["Sprocketwobble"]}' },
  { 'cspell.jsonc', '// Project dictionary\n{"version":"0.2","words":["Sprocketwobble"]}' },
  { 'cspell.yaml', 'version: "0.2"\nwords: [Sprocketwobble]' },
  { 'cspell.config.toml', 'version = "0.2"\nwords = ["Sprocketwobble"]' },
  { 'cspell.config.cjs', 'module.exports = { version: "0.2", words: ["Sprocketwobble"] };' },
}
local secure_read = vim.secure.read
vim.secure.read = function(path)
  assert(path:match('/5/cspell%.config%.cjs$'), path)
  return table.concat(vim.fn.readfile(path), '\n')
end
for i, fixture in ipairs(formats) do
  local project = root .. '/' .. i
  vim.fn.mkdir(project, 'p')
  vim.fn.writefile(vim.split(fixture[2], '\n'), project .. '/' .. fixture[1])
  vim.cmd.edit(project .. '/note.md')
  vim.bo.filetype = 'markdown'
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'Sprocketwobble wrod' })
  local config = dofile('lsp/cspell_ls.lua')
  config.name, config.root_dir = 'cspell_ls', project
  local id = assert(vim.lsp.start(config))
  local buf = vim.api.nvim_get_current_buf()
  assert(
    vim.wait(10000, function()
      local diagnostics = vim.diagnostic.get(buf)
      return #diagnostics == 1 and diagnostics[1].message:find('wrod', 1, true)
    end),
    'Missing CSpell diagnostics: ' .. fixture[1]
  )
  local diagnostics = vim.diagnostic.get(buf)
  assert(
    #diagnostics == 1 and diagnostics[1].message:find('wrod', 1, true),
    fixture[1] .. ' did not load its dictionary: ' .. vim.inspect(diagnostics)
  )
  vim.lsp.get_client_by_id(id):stop(true)
  vim.api.nvim_buf_delete(buf, { force = true })
end
vim.secure.read = secure_read

vim.cmd.edit(root .. '/SKILL.md')
vim.bo.filetype = 'markdown'
vim.api.nvim_buf_set_lines(0, 0, -1, false, {
  '---',
  'name: Invalid Name',
  'description: Test validation.',
  '---',
  '# Skill',
})
local config = dofile('lsp/agnix.lua')
config.name, config.root_dir = 'agnix', root
local id = assert(vim.lsp.start(config))
assert(
  vim.wait(10000, function()
    return #vim.diagnostic.get(0) > 0
  end),
  'agnix did not validate SKILL.md'
)
assert(vim.lsp.get_client_by_id(id):supports_method('textDocument/codeAction'))
vim.lsp.get_client_by_id(id):stop(true)
vim.cmd('bwipeout!')
vim.fn.delete(root, 'rf')
print('CSpell configuration formats and real agnix diagnostics: OK')
