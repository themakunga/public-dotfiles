local M = {}

local highlights = {
    fill = {
      guifg = { attribute = 'fg', highlight = '#ff0000' },
      guibg = { attribute = 'bg', highlight = 'TabLine' },
    },
    background = {
      guifg = { attribute = 'fg', highlight = 'TabLine' },
      guibg = { attribute = 'bg', highlight = 'TabLine' },
    },
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
    tab_selected = {
      guifg = { attribute = 'fg', highlight = 'Normal' },
      guibg = { attribute = 'bg', highlight = 'Normal' },
    },
    tab = {
      guifg = { attribute = 'fg', highlight = 'TabLine' },
      guibg = { attribute = 'bg', highlight = 'TabLine' },
    },
    tab_close = {
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
    indicator_selected = {
      guifg = { attribute = 'fg', highlight = 'LspDiagnosticsDefaultHint' },
      guibg = { attribute = 'bg', highlight = 'Normal' },
    },
  }

M.plugin = function()
    vim.pack.add({
    { src = 'https://github.com/akinsho/bufferline.nvim' },
  })

  if not Checker.check("bufferline") then
    return
  end

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

  require("bufferline").setup(opts)

  CMD.aucmd("bufferline-conf", {
    event = {'BufAdd', 'BufDelete' },
    callback = function()
            vim.schedule(function()
        pcall(require("bufferline").setup, opts)
      end)
    end
  })

  KM.bulk_map({
    {motion = "<leader>dp", cmd = ":BufferLineTogglePin<CR>", opts = { desc = 'Toggle Pin' }},
    {motion = "<leader>bP", cmd = ":BufferLineGroupClose ungrouped<CR>", opts = {desc = 'Delete Non-Pinned Buffers'}},
    {motion = "<leader>br", cmd = "<Cmd>BufferLineCloseRight<CR>", opts = {desc = 'Delete Buffers to the Right'}},
    {motion = "<leader>bl", cmd = "<Cmd>BufferLineCloseLeft<CR>", opts = { desc = "Delete Buffers to the Left"}},
    {motion = "<S-h>", cmd = "<cmd>BufferLineCyclePrev<cr>", opts = { desc = "Prev Buffer" }},
    {motion = "<S-l>", cmd = "<cmd>BufferLineCycleNext<cr>", opts = { desc = "Next Buffer"}},
    {motion = "[b", cmd = "<cmd>BufferLineCyclePrev<cr>", opts = { desc = "Prev Buffer"}},
    {motion = "]b", cmd = "<cmd>BufferLineCycleNext<cr>", opts = {desc = "Next Buffer"}},
    {motion = "[B", cmd = "<cmd>BufferLineMovePrev<cr>", opts = {desc = "Move buffer prev"}},
    {motion = "]B", cmd = "<cmd>BufferLineMoveNext<cr>", opts = {desc = "Move buffer next"}},
  })

end



return M

