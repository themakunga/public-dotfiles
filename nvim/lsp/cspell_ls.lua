local config_files = {
  'cspell.json',
  '.cspell.json',
  'cSpell.json',
  '.cSpell.json',
  'cspell.jsonc',
  '.cspell.jsonc',
  'cspell.yaml',
  '.cspell.yaml',
  'cspell.yml',
  '.cspell.yml',
}
for _, extension in ipairs({ 'json', 'jsonc', 'yaml', 'yml', 'js', 'cjs', 'mjs', 'ts', 'cts', 'mts', 'toml' }) do
  config_files[#config_files + 1] = 'cspell.config.' .. extension
  config_files[#config_files + 1] = '.cspell.config.' .. extension
end
for _, name in ipairs(vim.deepcopy(config_files)) do
  config_files[#config_files + 1] = '.config/' .. name
end
vim.list_extend(config_files, { '.vscode/cspell.json', '.vscode/cSpell.json', '.vscode/.cspell.json' })

---@type vim.lsp.Config
return {
  cmd = { 'cspell-language-server', '--stdio' },
  before_init = function(_, config)
    config.settings.cSpell.trustedWorkspace = false
    for _, name in ipairs(config_files) do
      if vim.fn.filereadable(config.root_dir .. '/' .. name) == 1 then
        if name:match('%.[cm]?[jt]s$') then
          -- Executable configs use Neovim's native file trust before CSpell loads them.
          config.settings.cSpell.trustedWorkspace = vim.secure.read(config.root_dir .. '/' .. name) ~= nil
        end
        return
      end
    end
  end,
  on_init = function(client)
    client:notify('_notifyConfigChange', { { client.config.settings.cSpell.trustedWorkspace == true } })
  end,
  settings = {
    cSpell = {
      -- shortcut: edit dictionaries in the project config; add client commands when needed.
      hideAddToDictionaryCodeActions = true,
    },
  },
  handlers = {
    ['_onWorkspaceConfigForDocumentRequest'] = function()
      return { words = {}, ignoreWords = {} }
    end,
  },
  commands = {
    ['cSpell.editText'] = function(command, ctx)
      local uri, version, edits = unpack(command.arguments)
      local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
      if vim.lsp.util.buf_versions[vim.uri_to_bufnr(uri)] > version then
        vim.notify('CSpell correction is stale; request code actions again.', vim.log.levels.WARN)
        return
      end
      vim.lsp.util.apply_workspace_edit({
        documentChanges = { { textDocument = { uri = uri, version = version }, edits = edits } },
      }, client.offset_encoding)
    end,
  },
  workspace_required = true,
  root_dir = function(bufnr, on_dir)
    -- A Git boundary prevents an unconfigured project inheriting a parent's opt-in.
    local root = vim.fs.root(bufnr, '.git')
      or vim.fs.root(bufnr, vim.list_extend(vim.deepcopy(config_files), { 'package.json' }))
    if not root then
      return
    end
    for _, name in ipairs(config_files) do
      if vim.fn.filereadable(root .. '/' .. name) == 1 then
        on_dir(root)
        return
      end
    end
    local package = root .. '/package.json'
    if vim.fn.filereadable(package) == 1 then
      local ok, data = pcall(function()
        return vim.json.decode(table.concat(vim.fn.readfile(package), '\n'))
      end)
      if ok and type(data) == 'table' and type(data.cspell) == 'table' then
        on_dir(root)
      end
    end
  end,
}
