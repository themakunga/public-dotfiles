local M = {}

local opts = {
  legacy_commands = false,
  picker = {
    name = 'fzf-lua',
  },
  workspaces = {
    {
      name = 'personal',
      path = '~/.vaults/personal',
    },
    {
      name = 'outcast',
      path = '~/.vaults/outcast',
    },
    {
      name = 'site-content',
      path = '~/Projects/Personal/personal-content',
      overrides = {
        templates = { folder = '.templates' },
        frontmatter = {
          func = function(note)
            local frontmatter = require('obsidian.builtin').frontmatter(note)
            if tostring(note.path:relative_to(Obsidian.workspace.root)):match('^posts/') then
              local schema_path = tostring(Obsidian.workspace.root / '.utils/frontmatter.schema.json')
              local schema = vim.json.decode(table.concat(vim.fn.readfile(schema_path), '\n'))
              for field, property in pairs(schema.properties) do
                if (frontmatter[field] == nil or frontmatter[field] == vim.NIL) and property.default ~= nil then
                  frontmatter[field] = vim.deepcopy(property.default)
                end
              end
              local now = os.date('%Y-%m-%dT%H:%M:%S%z')
              if frontmatter.created_at == nil or frontmatter.created_at == vim.NIL or frontmatter.created_at == '' then
                frontmatter.created_at = now
              end
              frontmatter.updated_at = now
              if frontmatter.audio == nil or frontmatter.audio == vim.NIL or frontmatter.audio == '' then
                frontmatter.audio = 'es-CL'
              end
              frontmatter.category = frontmatter.category or ''
            end
            return frontmatter
          end,
        },
      },
    },
    {
      name = 'journal',
      path = '~/.vaults/journal/',
    },
    {
      name = 'wiki',
      path = '~/.vaults/wiki',
    },
    {
      name = 'amgmt',
      path = '~/.vaults/amgmt',
    },
  },
}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/obsidian-nvim/obsidian.nvim', version = vim.version.range('*') },
  })

  if not Checker.check('obsidian') then
    return
  end

  require('obsidian').setup(opts)
end

return M
