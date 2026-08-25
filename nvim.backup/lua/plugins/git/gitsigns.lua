local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  })

  ---@module 'gitsigns'
  local ok, gitsigns = pcall(require, 'gitsigns')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] gitsigns ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  -- Higher-contrast gutter colors (GitHub-dark diff palette), kept
  -- applied across colorscheme reloads so Catppuccin can't pastel them.
  local function gitsigns_hl()
    local add, change, delete = '#56d364', '#e3b341', '#f85149'
    vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = add })
    vim.api.nvim_set_hl(0, 'GitSignsChange', { fg = change })
    vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = delete })
    vim.api.nvim_set_hl(0, 'GitSignsTopdelete', { fg = delete })
    vim.api.nvim_set_hl(0, 'GitSignsChangedelete', { fg = change })
  end

  gitsigns_hl()
  vim.api.nvim_create_autocmd('ColorScheme', { callback = gitsigns_hl })

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
    on_attach = function(bufnr)
      local gs = require('gitsigns')

      local function map(mode, l, r, options)
        options = options or {}
        options.buffer = bufnr
        vim.keymap.set(mode, l, r, options)
      end

      -- Navigation
      map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal({ ']c', bang = true })
        else
          gs.nav_hunk('next')
        end
      end, { desc = 'Jump to next git [c]hange' })

      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal({ '[c', bang = true })
        else
          gs.nav_hunk('prev')
        end
      end, { desc = 'Jump to previous git [c]hange' })

      -- Actions
      -- visual mode
      map('v', '<leader>ghs', function()
        gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end, { desc = 'Stage' })
      map('v', '<leader>ghr', function()
        gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end, { desc = 'Reset' })

      -- normal mode
      map('n', '<leader>ghs', gs.stage_hunk, { desc = 'Stage' })
      map('n', '<leader>ghr', gs.reset_hunk, { desc = 'Reset' })
      map('n', '<leader>ghu', gs.undo_stage_hunk, { desc = 'Undo' })
      map('n', '<leader>ghp', gs.preview_hunk, { desc = 'Preview' })
      map('n', '<leader>gbs', gs.stage_buffer, { desc = 'Buffer Stage' })
      map('n', '<leader>gbr', gs.reset_buffer, { desc = 'Buffer Reset' })
      map('n', '<leader>gbl', gs.blame_line, { desc = 'Blame Line' })
      map('n', '<leader>gdi', gs.diffthis, { desc = 'Diff Index' })
      map('n', '<leader>gdc', function()
        gs.diffthis('@')
      end, { desc = 'Diff Commit' })

      -- Toggles
      map('n', '<leader>gbl', gs.toggle_current_line_blame, { desc = 'Blame Line' })
      map('n', '<leader>gds', gs.toggle_deleted, { desc = 'Deleted Show' })
    end,
  }

  gitsigns.setup(opts)
end

return M
