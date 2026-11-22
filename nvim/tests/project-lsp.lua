-- Run from nvim/: nvim --headless -u NONE -i NONE -l tests/project-lsp.lua
local root = vim.fn.tempname()
vim.fn.mkdir(root .. '/parent/project/.git', 'p')
vim.fn.mkdir(root .. '/parent/project/docs', 'p')
root = assert(vim.uv.fs_realpath(root))
vim.fn.writefile({ '{}' }, root .. '/parent/cspell.json')
local project = root .. '/parent/project'
local buf = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_name(buf, project .. '/docs/note.md')
local cspell = dofile('lsp/cspell_ls.lua')
local function resolved(config)
  local found
  config.root_dir(buf, function(dir)
    found = dir
  end)
  return found
end
assert(not resolved(cspell), 'A parent config must not activate a nested Git project')
for _, name in ipairs({
  'cspell.json',
  '.cspell.jsonc',
  'cspell.config.toml',
  '.cspell.config.yml',
  'cspell.yaml',
  'cspell.config.js',
  '.cspell.config.mjs',
  'cspell.config.ts',
  '.config/cspell.config.yaml',
  '.vscode/cspell.json',
}) do
  vim.fn.mkdir(vim.fs.dirname(project .. '/' .. name), 'p')
  vim.fn.writefile({ '{}' }, project .. '/' .. name)
  assert(resolved(cspell) == project, name)
  vim.fn.delete(project .. '/' .. name)
end
for _, content in ipairs({ '{}', '{"name":"project"}', 'invalid JSON', '{"cspell":false}' }) do
  vim.fn.writefile({ content }, project .. '/package.json')
  assert(not resolved(cspell), content)
end
vim.fn.writefile({ '{"cspell":{"version":"0.2"}}' }, project .. '/package.json')
assert(resolved(cspell) == project)
vim.fn.delete(project .. '/package.json')
vim.fn.writefile({ '{}' }, project .. '/docs/cspell.json')
assert(not resolved(cspell), 'Only root configuration opts a Git project in')
vim.fn.writefile({ 'return {}' }, project .. '/cspell.lua')
assert(not resolved(cspell), 'Lua is not a CSpell configuration format')
vim.fn.mkdir(project .. '/nested/.git', 'p')
vim.fn.writefile({ '{}' }, project .. '/cspell.json')
vim.api.nvim_buf_set_name(buf, project .. '/nested/note.md')
assert(not resolved(cspell), 'Nested repositories opt in independently')
vim.api.nvim_buf_set_name(buf, root .. '/standalone/cspell-note.md')
vim.fn.mkdir(root .. '/standalone', 'p')
vim.fn.writefile({ '{}' }, root .. '/standalone/cspell.json')
assert(resolved(cspell) == root .. '/standalone', 'Non-Git projects can opt in')
local secure_read = vim.secure.read
local init_config = { root_dir = root .. '/standalone', settings = vim.deepcopy(cspell.settings) }
vim.secure.read = function()
  error('Data-only configuration must not prompt for execution trust')
end
cspell.before_init({}, init_config)
assert(init_config.settings.cSpell.trustedWorkspace == false)
vim.fn.delete(root .. '/standalone/cspell.json')
vim.fn.writefile({ 'module.exports = {}' }, root .. '/standalone/cspell.config.cjs')
vim.secure.read = function()
  return nil
end
cspell.before_init({}, init_config)
assert(init_config.settings.cSpell.trustedWorkspace == false, 'Denied executable configuration remains untrusted')
vim.secure.read = secure_read

local agnix = dofile('lsp/agnix.lua')
for _, name in ipairs({
  'SKILL.md',
  'AGENTS.md',
  'AGENTS.override.md',
  'CLAUDE.md',
  '.claude/agents/reviewer.md',
  '.claude/settings.json',
  '.cursor/rules/project.mdc',
  '.github/instructions/code.instructions.md',
  'mcp.json',
}) do
  vim.api.nvim_buf_set_name(buf, project .. '/' .. name)
  assert(resolved(agnix) == project, name)
end
for _, name in ipairs({ 'README.md', 'package.json', 'settings.json', 'random.toml' }) do
  vim.api.nvim_buf_set_name(buf, project .. '/' .. name)
  assert(not resolved(agnix), name)
end
vim.api.nvim_buf_delete(buf, { force = true })
vim.fn.delete(root, 'rf')
print('CSpell project opt-in and targeted agnix attachment: OK')
