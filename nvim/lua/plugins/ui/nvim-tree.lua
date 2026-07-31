local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/MunifTanjim/nui.nvim' },
    { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
    { src = 'https://github.com/antosha417/nvim-lsp-file-operations' },
  })

  ---@module 'nvim-tree'
  local ok_tree, nvimtree = pcall(require, 'nvim-tree')

  if not ok_tree then
    vim.notify('[CHECK REQUIRE FAILED] nvim-tree ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  ---@module 'lsp-file-operations'
  local ok_lsp_ops, lsp_file_operations = pcall(require, 'lsp-file-operations')
  if not ok_lsp_ops then
    vim.notify('[CHECK REQUIRE FAILED] lsp-file-operations ' .. debug.getinfo(2).source, vim.log.levels.WARN)
  else
    lsp_file_operations.setup()
  end

  local opts = {
    reload_on_bufenter = true,
    hijack_cursor = true,
    hijack_netrw = true,
    sync_root_with_cwd = true,
    hijack_unnamed_buffer_when_opening = true,
    auto_reload_on_write = true,
    diagnostics = {
      enable = false,
    },
    hijack_directories = {
      enable = true,
      auto_open = true,
    },
    actions = {
      open_file = {
        quit_on_open = true,
        resize_window = true,
      },
    },
    update_focused_file = {
      enable = true,
    },
    view = {
      centralize_selection = true,
      adaptive_size = false,
      side = 'right',
      preserve_window_proportions = true,
      width = 40,
    },
    renderer = {
      full_name = false,
      indent_markers = {
        enable = false,
      },
      root_folder_label = ':t',
      highlight_git = true,
    },
    filters = {
      dotfiles = false,
      git_ignored = false,
      git_clean = false,
      no_buffer = false,
    },
    git = {
      enable = true,
      ignore = false,
      timeout = 1000,
    },
  }

  local function keybindings(bufnr)
    local api = require('nvim-tree.api')

    local function ops(desc)
      return {
        desc = 'nvim-tree: ' .. desc,
        buffer = bufnr,
        noremap = true,
        silent = true,
        nowait = true,
      }
    end

    -- default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- custom mappings
    vim.keymap.set('n', 'P', api.node.open.preview, ops('Preview'))
    vim.keymap.set('n', 's', api.node.open.vertical_no_picker, ops('Open Horizontal'))
    vim.keymap.set('n', 'S', api.node.open.horizontal_no_picker, ops('Open Vertical'))
  end

  opts.on_attach = keybindings

  nvimtree.setup(opts)

  local function open_tree_on_setup(args)
    vim.schedule(function()
      local file = args.file
      local buf_name = vim.api.nvim_buf_get_name(0)
      local is_no_name_buffer = buf_name == '' and vim.bo.filetype == '' and vim.bo.buftype == ''
      local is_directory = vim.fn.isdirectory(file) == 1

      if not is_no_name_buffer and not is_directory then
        return
      end

      if is_directory then
        vim.cmd.cd(file)
      end

      require('nvim-tree.api').tree.open()
    end)
  end

  vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('nvim-tree', { clear = true }),
    callback = open_tree_on_setup,
  })

  vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = 'Open Explorer' })
end

return M
