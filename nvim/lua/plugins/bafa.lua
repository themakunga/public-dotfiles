local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/mistweaverco/bafa.nvim', name = 'bafa', version = 'v1.4.1' },
  })

  local ok, bafa = pcall(require, 'bafa')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] bafa ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local bafa_opts = {
    title = 'Current Buffers',
    title_pos = 'center',
    border = 'rounded',
    style = 'minimal',
    diagnostics = true, -- Show diagnostics in the buffer list
    line_numbers = false, -- Show line numbers in the buffer list
    icons = {
      diagnostics = {
        Error = '', -- Icon for error diagnostics
        Warn = '', -- Icon for warning diagnostics
        Info = '', -- Icon for info diagnostics
        Hint = '', -- Icon for hint diagnostics
      },
      sign = {
        changes = '┃', -- Sign character for modified/deleted buffers
      },
    },
    hl = {
      modified = 'DiffChange', -- Highlight group for modified buffer text (fallback: GitSignsChange, WarningMsg)
      sign = {
        modified = 'GitSignsChange', -- Highlight group for modified buffer signs (fallback: DiffChange)
        deleted = 'GitSignsDelete', -- Highlight group for deleted buffer signs (fallback: DiffDelete)
      },
    },
    notify = {
      provider = 'notify', -- "notify" or "print"
    },
  }

  bafa.setup(bafa_opts)

  vim.keymap.set('n', '<leader>b', function()
    require('bafa.ui').toggle()
  end, { desc = 'Toggle Buffer manager' })
end

return M
