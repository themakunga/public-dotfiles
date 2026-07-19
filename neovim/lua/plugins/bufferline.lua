local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/akinsho/bufferline.nvim' },
  })

  ---@module 'bufferline'
  local ok, bufferline = pcall(require, 'bufferline')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] bufferline ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local highlights = {
    fill = {
      guifg = { attribute = 'fg', highlight = '#ff0000' },
      guibg = { attribute = 'bg', highlight = 'TabLine' },
    },
    background = {
      guifg = { attribute = 'fg', highlight = 'TabLine' },
      guibg = { attribute = 'bg', highlight = 'TabLine' },
    },

    -- buffer_selected = {
    --   guifg = {attribute='fg',highlight='#ff0000'},
    --   guibg = {attribute='bg',highlight='#0000ff'},
    --   gui = 'none'
    --   },
    buffer_visible = {
      guifg = { attribute = 'fg', highlight = 'TabLine' },
      guibg = { attribute = 'bg', highlight = 'TabLine' },
    },

    close_button = {
      guifg = { attribute = 'fg', highlight = 'TabLine' },
      guibg = { attribute = 'bg', highlight = 'TabLine' },
    },
    close_button_visible = {
      guifg = { attribute = 'fg', highlight = 'TabLine' },
      guibg = { attribute = 'bg', highlight = 'TabLine' },
    },
    -- close_button_selected = {
    --   guifg = {attribute='fg',highlight='TabLineSel'},
    --   guibg ={attribute='bg',highlight='TabLineSel'}
    --   },

    tab_selected = {
      guifg = { attribute = 'fg', highlight = 'Normal' },
      guibg = { attribute = 'bg', highlight = 'Normal' },
    },
    tab = {
      guifg = { attribute = 'fg', highlight = 'TabLine' },
      guibg = { attribute = 'bg', highlight = 'TabLine' },
    },
    tab_close = {
      -- guifg = {attribute='fg',highlight='LspDiagnosticsDefaultError'},
      guifg = { attribute = 'fg', highlight = 'TabLineSel' },
      guibg = { attribute = 'bg', highlight = 'Normal' },
    },

    duplicate_selected = {
      guifg = { attribute = 'fg', highlight = 'TabLineSel' },
      guibg = { attribute = 'bg', highlight = 'TabLineSel' },
      gui = 'italic',
    },
    duplicate_visible = {
      guifg = { attribute = 'fg', highlight = 'TabLine' },
      guibg = { attribute = 'bg', highlight = 'TabLine' },
      gui = 'italic',
    },
    duplicate = {
      guifg = { attribute = 'fg', highlight = 'TabLine' },
      guibg = { attribute = 'bg', highlight = 'TabLine' },
      gui = 'italic',
    },

    modified = {
      guifg = { attribute = 'fg', highlight = 'TabLine' },
      guibg = { attribute = 'bg', highlight = 'TabLine' },
    },
    modified_selected = {
      guifg = { attribute = 'fg', highlight = 'Normal' },
      guibg = { attribute = 'bg', highlight = 'Normal' },
    },
    modified_visible = {
      guifg = { attribute = 'fg', highlight = 'TabLine' },
      guibg = { attribute = 'bg', highlight = 'TabLine' },
    },

    separator = {
      guifg = { attribute = 'bg', highlight = 'TabLine' },
      guibg = { attribute = 'bg', highlight = 'TabLine' },
    },
    separator_selected = {
      guifg = { attribute = 'bg', highlight = 'Normal' },
      guibg = { attribute = 'bg', highlight = 'Normal' },
    },
    -- separator_visible = {
    --   guifg = {attribute='bg',highlight='TabLine'},
    --   guibg = {attribute='bg',highlight='TabLine'}
    --   },
    indicator_selected = {
      guifg = { attribute = 'fg', highlight = 'LspDiagnosticsDefaultHint' },
      guibg = { attribute = 'bg', highlight = 'Normal' },
    },
  }

  --@type bufferline.SetupOps
  local opts = {
    options = {
      close_command = function(n)
        require('snacks').bufdelete(n)
      end,
      right_mouse_command = function(n)
        require('snacks').bufdelete(n)
      end,
      numbers = 'none',
      middle_mouse_command = nil,
      indicator_icon = '▎',
      buffer_close_icon = '',
      modified_icon = '●',
      close_icon = '',
      left_trunc_marker = '',
      right_trunc_marker = '',
      max_name_length = 30,
      max_prefix_length = 30, -- prefix used when a buffer is de-duplicated
      tab_size = 21,
      diagnostics = false, -- | "nvim_lsp" | "coc",
      diagnostics_update_in_insert = false,
      always_show_bufferline = true,

      offsets = { { filetype = 'NvimTree', text = '', padding = 1 } },
      highlights = highlights,
    },
  }

  bufferline.setup(opts)

  vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
    callback = function()
      vim.schedule(function()
        pcall(bufferline)
      end)
    end,
  })

  vim.keymap.set('n', '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', { desc = 'Toggle Pin' })
  vim.keymap.set('n', '<leader>bP', '<Cmd>BufferLineGroupClose ungrouped<CR>', { desc = 'Delete Non-Pinned Buffers' })
  vim.keymap.set('n', '<leader>br', '<Cmd>BufferLineCloseRight<CR>', { desc = 'Delete Buffers to the Right' })
  vim.keymap.set('n', '<leader>bl', '<Cmd>BufferLineCloseLeft<CR>', { desc = 'Delete Buffers to the Left' })
  vim.keymap.set('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev Buffer' })
  vim.keymap.set('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next Buffer' })
  vim.keymap.set('n', '[b', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev Buffer' })
  vim.keymap.set('n', ']b', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next Buffer' })
  vim.keymap.set('n', '[B', '<cmd>BufferLineMovePrev<cr>', { desc = 'Move buffer prev' })
  vim.keymap.set('n', ']B', '<cmd>BufferLineMoveNext<cr>', { desc = 'Move buffer next' })

  -- vim.keymap.set('n', '<leader>ee', '<cmd>bufferline<cr>', {desc = "Open parent directory"})
end

return M
