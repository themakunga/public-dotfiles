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
