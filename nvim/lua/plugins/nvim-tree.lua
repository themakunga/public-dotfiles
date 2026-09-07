local M = {}

local function on_attach(bufnr)
  local api = require('nvim-tree.api')

  api.map.on_attach.default(bufnr)

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  KM.bulk_map({
    { mode = 'n', motion = 'e', cmd = api.tree.close, opts = opts('Close panel (toggle)') },
    { mode = 'n', motion = 'r', cmd = api.fs.rename, opts = opts('Rename') },
    { mode = 'n', motion = 'a', cmd = api.fs.create, opts = opts('Create') },
    { mode = 'n', motion = 'd', cmd = api.fs.remove, opts = opts('Delete') },
    { mode = 'n', motion = 'c', cmd = api.fs.copy.node, opts = opts('Copy') },
    { mode = 'n', motion = 'x', cmd = api.fs.cut, opts = opts('Cut / Move') },
    { mode = 'n', motion = 'p', cmd = api.fs.paste, opts = opts('Paste') },

    { mode = 'n', motion = '<Tab>', cmd = api.node.open.preview, opts = opts('Preview') },
    { mode = 'n', motion = 's', cmd = api.node.open.vertical, opts = opts('Open Vertical') },
    { mode = 'n', motion = 'S', cmd = api.node.open.horizontal, opts = opts('Open Horizontal') },

    {
      mode = 'n',
      motion = 'O',
      cmd = function()
        local node = api.tree.get_node_under_cursor()
        if node then
          vim.ui.open(node.absolute_path)
        end
      end,
      opts = opts('Open in File Explorer'),
    },
  })
end

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
    { src = 'https://github.com/antosha417/nvim-lsp-file-operations' },
  })

  local opts = {
    hijack_cursor = true,
    sync_root_with_cwd = true,
    on_attach = on_attach,
    view = {
      side = 'right',
      width = 40,
    },
    renderer = {
      highlight_git = true,
      indent_markers = { enable = false },
    },
    git = { enable = true },

    filters = {
      dotfiles = false,
      custom = { '^\\.git$' },
    },
  }

  require('nvim-tree').setup(opts)

  KM.map({
    mode = 'n',
    motion = '<leader>ee',
    cmd = function()
      local api = require('nvim-tree.api')

      if api.tree.is_visible() then
        if vim.bo.filetype == 'NvimTree' then
          api.tree.close()
        else
          api.tree.focus()
        end
      else
        api.tree.open()
      end
    end,
    opts = { desc = 'nvim-tree: Toggle/Focus' },
  })
end

return M
