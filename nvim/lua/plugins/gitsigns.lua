local M = {}
local function gitsigns_hl()
  local add, change, delete = '#56d364', '#e3b341', '#f85149'
  vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = add })
  vim.api.nvim_set_hl(0, 'GitSignsChange', { fg = change })
  vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = delete })
  vim.api.nvim_set_hl(0, 'GitSignsTopdelete', { fg = delete })
  vim.api.nvim_set_hl(0, 'GitSignsChangedelete', { fg = change })
end

local function on_attach(bufnr)
  local gs = require('gitsigns')

  KM.bulk_map({
    {
      motion = ']c',
      cmd = function()
        if vim.wo.diff then
          vim.cmd.normal({ ']c', bang = true })
        else
          gs.nav_hunk('next')
        end
      end,
      opts = { buffer = bufnr, desc = 'Jump to next git [c]hange' },
    },
    {
      motion = '[c',
      cmd = function()
        if vim.wo.diff then
          vim.cmd.normal({ '[c', bang = true })
        else
          gs.nav_hunk('prev')
        end
      end,
      opts = { buffer = bufnr, desc = 'Jump to previous git [c]hange' },
    },
    {
      mode = 'v',
      motion = '<leader>ghs',
      cmd = function()
        gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end,
      opts = { buffer = bufnr, desc = 'Stage' },
    },
    {
      mode = 'v',
      motion = '<leader>ghr',
      cmd = function()
        gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end,
      opts = { buffer = bufnr, desc = 'Reset' },
    },
    {
      motion = '<leader>ghs',
      cmd = gs.stage_hunk,
      opts = { buffer = bufnr, desc = 'Stage' },
    },
    {
      motion = '<leader>ghr',
      cmd = gs.reset_hunk,
      opts = { buffer = bufnr, desc = 'Reset' },
    },
    {
      motion = '<leader>ghu',
      cmd = gs.undo_stage_hunk,
      opts = { buffer = bufnr, desc = 'Undo' },
    },
    {
      motion = '<leader>ghp',
      cmd = gs.preview_hunk,
      opts = { buffer = bufnr, desc = 'Previous' },
    },
    {
      motion = '<leader>gbs',
      cmd = gs.stage_buffer,
      opts = { buffer = bufnr, desc = 'Buffer Stage' },
    },
    {
      motion = '<leader>gbr',
      cmd = gs.reset_hunk,
      opts = { buffer = bufnr, desc = 'Buffer Reset' },
    },
    {
      motion = '<leader>gbb',
      cmd = gs.blame_line,
      opts = { buffer = bufnr, desc = 'Blame Line' },
    },
    {
      motion = '<leader>gdi',
      cmd = gs.diffthis,
      opts = { buffer = bufnr, desc = 'Diff Index' },
    },
    {
      motion = '<leader>gdc',
      cmd = function()
        gs.diffthis('@')
      end,
      opts = { buffer = bufnr, desc = 'Diff Commit' },
    },
    {
      motion = '<leader>gbl',
      cmd = gs.toggle_current_line_blame,
      opts = { buffer = bufnr, desc = 'Toggle line blanme' },
    },
    {
      motion = '<leader>gds',
      cmd = gs.toggle_deleted,
      opts = { buffer = bufnr, desc = 'Git delete show' },
    },
  })
end

local opts = {
  signs = {
    add = { text = '▌' },
    change = { text = '▌' },
    delete = { text = '▁' },
    topdelete = { text = '▔' },
    changedelete = { text = '▌' },
  },
  signs_staged = {
    add = { text = '▌' },
    change = { text = '▌' },
    delete = { text = '▁' },
    topdelete = { text = '▔' },
    changedelete = { text = '▌' },
  },
  on_attach = on_attach,
}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  })

  if not Checker.check('gitsigns') then
    return
  end
  gitsigns_hl()
  vim.api.nvim_create_autocmd('ColorScheme', { callback = gitsigns_hl })

  require('gitsigns').setup(opts)
end

return M
