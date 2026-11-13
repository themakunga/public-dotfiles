local M = {}

local opts = {
  legacy_commands = false,
  picker = {
    name = 'fzf-lua',
  },
  ui = {
    enable = false,
  },
  frontmatter = {
    func = function(note)
      local frontmatter = require('obsidian.builtin').frontmatter(note)
      local now = os.date('%Y-%m-%dT%H:%M:%S%z')
      frontmatter.created_at = frontmatter.created_at or now
      frontmatter.updated_at = now
      if frontmatter.draft == nil then
        frontmatter.draft = false
      end
      return frontmatter
    end,
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
            local relative = tostring(note.path:relative_to(Obsidian.workspace.root))
            local article = relative:match('^posts/')
            local portfolio = relative:match('^portfolio/')
            if not article and not portfolio then
              return frontmatter
            end
            local schema_name = article and 'article.frontmatter.schema.json' or 'portfolio.frontmatter.schema.json'
            local schema_path = tostring(Obsidian.workspace.root / ('.utils/' .. schema_name))
            if article and vim.fn.filereadable(schema_path) == 0 then
              local legacy_path = tostring(Obsidian.workspace.root / '.utils/frontmatter.schema.json')
              if vim.fn.filereadable(legacy_path) == 1 then
                schema_path = legacy_path
              end
            end
            local ok, schema = pcall(function()
              return vim.json.decode(table.concat(vim.fn.readfile(schema_path), '\n'))
            end)
            if ok and type(schema) == 'table' and type(schema.properties) == 'table' then
              for field, property in pairs(schema.properties) do
                if
                  type(property) == 'table'
                  and (frontmatter[field] == nil or frontmatter[field] == vim.NIL)
                  and property.default ~= nil
                then
                  frontmatter[field] = vim.deepcopy(property.default)
                end
              end
            else
              vim.notify_once('Obsidian: schema unavailable or invalid: ' .. schema_path, vim.log.levels.WARN)
            end
            if article then
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

  -- Obsidian's save hook excludes repository documents and files outside its workspaces.
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('obsidian_frontmatter_on_save', { clear = true }),
    pattern = { '*.md', '*.markdown' },
    callback = function(args)
      if vim.bo[args.buf].buftype ~= '' or vim.b[args.buf].obsidian_help then
        return
      end
      local note = require('obsidian.note').from_buffer(args.buf)
      if note.has_frontmatter and not note.frontmatter_end_line then
        return
      end
      pcall(vim.cmd, 'undojoin')
      note:save_to_buffer({ bufnr = args.buf })
    end,
  })
end

return M
