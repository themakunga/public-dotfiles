local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-telescope/telescope.nvim' },
    { src = 'https://github.com/folke/todo-comments.nvim' },
    { src = 'https://github.com/nvim-telescope/telescope-ui-select.nvim' },
    { src = 'https://github.com/nvim-telescope/telescope-media-files.nvim' },
    { src = 'https://github.com/jemag/telescope-diff.nvim' },
  })

  --@module 'telescope'
  local ok, telescope = pcall(require, 'telescope')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] telescope ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local actions = require('telescope.actions')

  require('telescope').load_extension('ui-select')
  require('telescope').load_extension('media_files')
  require('telescope').load_extension('diff')

  local function normalize_path(path)
    return path:gsub('\\', '/')
  end

  local function normalize_cwd()
    return normalize_path(vim.loop.cwd()) .. '/'
  end

  local function is_subdirectory(cwd, path)
    return string.lower(path:sub(1, #cwd)) == string.lower(cwd)
  end

  local function split_filepath(path)
    local normalized_path = normalize_path(path)
    local normalized_cwd = normalize_cwd()
    local filename = normalized_path:match('[^/]+$')

    if is_subdirectory(normalized_cwd, normalized_path) then
      local stripped_path = normalized_path:sub(#normalized_cwd + 1, -(#filename + 1))
      return stripped_path, filename
    else
      local stripped_path = normalized_path:sub(1, -(#filename + 1))
      return stripped_path, filename
    end
  end

  local function path_display(_, path)
    local stripped_path, filename = split_filepath(path)
    if filename == stripped_path or stripped_path == '' then
      return filename
    end
    return string.format('%s ~ %s', filename, stripped_path)
  end

  local mappings = {
    i = {
      ['<C-n>'] = actions.cycle_history_next,
      ['<C-p>'] = actions.cycle_history_prev,

      ['<C-j>'] = actions.move_selection_next,
      ['<C-k>'] = actions.move_selection_previous,

      ['<C-c>'] = actions.close,

      ['<Down>'] = actions.move_selection_next,
      ['<Up>'] = actions.move_selection_previous,

      ['<CR>'] = actions.select_default,
      ['<C-x>'] = actions.select_horizontal,
      ['<C-v>'] = actions.select_vertical,
      ['<C-t>'] = actions.select_tab,

      ['<C-u>'] = actions.preview_scrolling_up,
      ['<C-d>'] = actions.preview_scrolling_down,

      ['<PageUp>'] = actions.results_scrolling_up,
      ['<PageDown>'] = actions.results_scrolling_down,

      ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
      ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
      ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
      ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
      ['<C-l>'] = actions.complete_tag,
      ['<C-_>'] = actions.which_key, -- keys from pressing <C-/>
    },

    n = {
      ['<esc>'] = actions.close,
      ['<CR>'] = actions.select_default,
      ['<C-x>'] = actions.select_horizontal,
      ['<C-v>'] = actions.select_vertical,
      ['<C-t>'] = actions.select_tab,

      ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
      ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
      ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
      ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,

      ['j'] = actions.move_selection_next,
      ['k'] = actions.move_selection_previous,
      ['H'] = actions.move_to_top,
      ['M'] = actions.move_to_middle,
      ['L'] = actions.move_to_bottom,

      ['<Down>'] = actions.move_selection_next,
      ['<Up>'] = actions.move_selection_previous,
      ['gg'] = actions.move_to_top,
      ['G'] = actions.move_to_bottom,

      ['<C-u>'] = actions.preview_scrolling_up,
      ['<C-d>'] = actions.preview_scrolling_down,

      ['<PageUp>'] = actions.results_scrolling_up,
      ['<PageDown>'] = actions.results_scrolling_down,

      ['?'] = actions.which_key,
    },
  }

  local pickers = {
    find_files = {
      hidden = true,
    },
    git_files = {
      shown_untracked = true,
    },
  }

  local file_ignore_patterns = {
    'node_modules',
    '.git',
  }

  local extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown({}),
    },
    media_files = {
      -- filetypes whitelist
      -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
      filetypes = { 'png', 'webp', 'jpg', 'jpeg' },
      find_cmd = 'fd', -- find command (defaults to `fd`)
    },
  }

  local opts = {
    defaults = {
      prompt_prefix = ' 󱡴 ',
      selection_caret = '󰁔 ',
      path_display = path_display,
      mappings = mappings,
      file_ignore_patterns = file_ignore_patterns,
    },
    extensions = extensions,
    pickers = pickers,
  }

  telescope.setup(opts)

  vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = '[f]ind [f]iles in cwd' })
  vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { desc = '[f]ind [b]uffers in cwd' })
  vim.keymap.set('n', '<leader>fg', '<cmd>Telescope grep_string<CR>', { desc = '[f]ind [g]rep in cwd' })
  vim.keymap.set('n', '<leader>fr', '<cmd>Telescope oldfiles<CR>', { desc = '[f]ind [r]ecent files' })
  vim.keymap.set('n', '<leader>fs', '<cmd>Telescope live_grep<CR>', { desc = '[f]ind [s]tring in cwd' })
  vim.keymap.set('n', '<leader>fc', '<cmd>Telescope grep_string<CR>', { desc = '[f]ind string under [c]ursor in cwd' })
  vim.keymap.set('n', '<leader>fdC', function()
    require('telescope').extensions.diff.diff_files({ hidden = true })
  end, { desc = '[C]ompare 2 files' })
  vim.keymap.set('n', '<leader>fdc', function()
    require('telescope').extensions.diff.diff_current({ hidden = true })
  end, { desc = 'Compare file with [c]urrent' })
end

return M
