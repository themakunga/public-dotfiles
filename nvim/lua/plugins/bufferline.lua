local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/akinsho/bufferline.nvim' },
  })

  if not Checker.check('bufferline') then
    return
  end

  -- shortcut: Bufferline only supports paired caps through slant; use a native rounded style when available.
  require('bufferline.constants').sep_chars.slant = { '', '' }

  local colors = require('tokyonight.colors').setup()
  local highlights = { fill = { bg = 'NONE' } }
  for _, state in ipairs({
    { suffix = '', buffer = 'background', fg = colors.fg_dark, bg = colors.bg_dark },
    { suffix = '_visible', buffer = 'buffer_visible', fg = colors.fg, bg = colors.bg_highlight },
    { suffix = '_selected', buffer = 'buffer_selected', fg = colors.bg_dark, bg = colors.blue },
  }) do
    highlights[state.buffer] = { fg = state.fg, bg = state.bg, bold = state.suffix == '_selected', italic = false }
    highlights['separator' .. state.suffix] = { fg = state.bg, bg = 'NONE' }
    for _, group in ipairs({ 'close_button', 'modified', 'duplicate' }) do
      highlights[group .. state.suffix] = { fg = state.fg, bg = state.bg, italic = false }
    end
  end

  local opts = {
    highlights = highlights,
    options = {
      close_command = function(n)
        require('snacks').bufdelete(n)
      end,
      right_mouse_command = function(n)
        require('snacks').bufdelete(n)
      end,
      numbers = 'none',
      middle_mouse_command = nil,
      indicator = { style = 'none' },
      separator_style = 'slant',
      buffer_close_icon = '',
      modified_icon = '●',
      close_icon = '',
      left_trunc_marker = '',
      right_trunc_marker = '',
      max_name_length = 30,
      max_prefix_length = 30, -- prefix used when a buffer is de-duplicated
      tab_size = 16,
      diagnostics = false, -- | "nvim_lsp" | "coc",
      diagnostics_update_in_insert = false,
      always_show_bufferline = true,

      offsets = { { filetype = 'NvimTree', text = '', padding = 1 } },
    },
  }

  require('bufferline').setup(opts)

  CMD.aucmd('bufferline-conf', {
    event = { 'BufAdd', 'BufDelete' },
    callback = function()
      vim.schedule(function()
        pcall(bufferline)
      end)
    end,
  })

  KM.bulk_map({
    { motion = '<leader>dp', cmd = ':BufferLineTogglePin<CR>', opts = { desc = 'Toggle Pin' } },
    {
      motion = '<leader>bP',
      cmd = ':BufferLineGroupClose ungrouped<CR>',
      opts = { desc = 'Delete Non-Pinned Buffers' },
    },
    { motion = '<leader>br', cmd = '<Cmd>BufferLineCloseRight<CR>', opts = { desc = 'Delete Buffers to the Right' } },
    { motion = '<leader>bl', cmd = '<Cmd>BufferLineCloseLeft<CR>', opts = { desc = 'Delete Buffers to the Left' } },
    { motion = '<S-h>', cmd = '<cmd>BufferLineCyclePrev<cr>', opts = { desc = 'Prev Buffer' } },
    { motion = '<S-l>', cmd = '<cmd>BufferLineCycleNext<cr>', opts = { desc = 'Next Buffer' } },
    { motion = '[b', cmd = '<cmd>BufferLineCyclePrev<cr>', opts = { desc = 'Prev Buffer' } },
    { motion = ']b', cmd = '<cmd>BufferLineCycleNext<cr>', opts = { desc = 'Next Buffer' } },
    { motion = '[B', cmd = '<cmd>BufferLineMovePrev<cr>', opts = { desc = 'Move buffer prev' } },
    { motion = ']B', cmd = '<cmd>BufferLineMoveNext<cr>', opts = { desc = 'Move buffer next' } },
  })
end

return M
