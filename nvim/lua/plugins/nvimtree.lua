local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/kyazdani42/nvim-tree.lua' },
  })

  --@module 'nvim_tree'
  local ok, nvim_tree = pcall(require, 'nvim-tree')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] nvim_tree ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local update_focused_file = {
    enable = true,
    update_root = true,
    update_cwd = true,
  }

  local view = {
    width = 35,
    relativenumber = false,
    side = 'left',
  }

  local icons = {
    glyphs = {
      default = '',
      symlink = '',
      bookmark = '◉',
      folder = {
        default = '',
        open = '',
        symlink = '',
      },
      git = {
        deleted = '',
        ignored = '◌',
        renamed = '➜',
        staged = '✓',
        unmerged = '',
        unstaged = '✗',
        untracked = '★',
      },
    },
    show = {
      git = false,
      file = true,
      folder = true,
      folder_arrow = false,
    },
  }

  local renderer = {
    highlight_git = true,
    root_folder_modifier = ':t',
    indent_markers = {
      enable = true,
    },
    icons = icons,
  }

  local actions = {
    open_file = {
      resize_window = true,
      window_picker = {
        enable = false,
      },
    },
  }

  local filters = {
    custom = {
      '.DS_Store',
    },
    dotfiles = false,
  }
  local git = {
    ignore = false,
  }
  --@type nvim_tree.SetupOps
  local opts = {
    hijack_cursor = true,
    open_on_tab = true,
    update_cwd = true,
    update_focused_file = update_focused_file,
    view = view,
    renderer = renderer,
    actions = actions,
    filters = filters,
    git = git,
  }

  nvim_tree.setup(opts)

  vim.keymap.set('n', '<leader>ee', '<cmd>NvimTreeFocus<cr>', { desc = 'Toggle Nvim Tree' })
end

return M
