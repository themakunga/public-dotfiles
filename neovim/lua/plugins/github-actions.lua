local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/skanehira/github-actions.nvim' },
  })

  local ok, actions = pcall(require, 'github-actions')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] github-actions ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local opts = {
    actions = {
      enabled = true, -- Enable version checking (default: true)
      icons = {
        outdated = '', -- Icon for outdated versions (default)
        latest = '', -- Icon for latest versions (default)
        error = '', -- Icon for error (default)
      },
      highlight_latest = 'GitHubActionsVersionLatest', -- Highlight for latest versions
      highlight_outdated = 'GitHubActionsVersionOutdated', -- Highlight for outdated versions
      highlight_error = 'GitHubActionsVersionError', -- Highlight for error
      highlight_icon_latest = 'GitHubActionsIconLatest', -- Highlight for latest icon
      highlight_icon_outdated = 'GitHubActionsIconOutdated', -- Highlight for outdated icon
      highlight_icon_error = 'GitHubActionsIconError', -- Highlight for error icon
    },
    history = {
      icons = {
        success = '✓', -- Icon for successful runs (default)
        failure = '✗', -- Icon for failed runs (default)
        cancelled = '⊘', -- Icon for cancelled runs (default)
        skipped = '⊘', -- Icon for skipped runs (default)
        in_progress = '⊙', -- Icon for in-progress runs (default)
        queued = '○', -- Icon for queued runs (default)
        waiting = '○', -- Icon for waiting runs (default)
        unknown = '?', -- Icon for unknown status runs (default)
      },
      highlights = {
        success = 'GitHubActionsHistorySuccess', -- Highlight for successful runs
        failure = 'GitHubActionsHistoryFailure', -- Highlight for failed runs
        cancelled = 'GitHubActionsHistoryCancelled', -- Highlight for cancelled runs
        running = 'GitHubActionsHistoryRunning', -- Highlight for running runs
        queued = 'GitHubActionsHistoryQueued', -- Highlight for queued runs
        run_id = 'GitHubActionsHistoryRunId', -- Highlight for run ID
        branch = 'GitHubActionsHistoryBranch', -- Highlight for branch name
        time = 'GitHubActionsHistoryTime', -- Highlight for time information
        header = 'GitHubActionsHistoryHeader', -- Highlight for header
        separator = 'GitHubActionsHistorySeparator', -- Highlight for separator
      },
      -- Optional: customize highlight colors globally
      highlight_colors = {
        success = { fg = '#10b981', bold = true }, -- Highlight for successful runs
        failure = { fg = '#ef4444', bold = true }, -- Highlight for failed runs
        cancelled = { fg = '#6b7280', bold = true }, -- Highlight for cancelled runs
        running = { fg = '#f59e0b', bold = true }, -- Highlight for running runs
        queued = { fg = '#8b5cf6', bold = true }, -- Highlight for queued runs
      },
      -- Optional: customize keymaps for history buffers
      keymaps = {
        list = { -- Workflow run list buffer
          close = 'q', -- Close the buffer
          expand = 'l', -- Expand/collapse run or view logs
          collapse = 'h', -- Collapse expanded run
          refresh = 'r', -- Refresh history
          rerun = 'R', -- Rerun workflow
          dispatch = 'd', -- Dispatch workflow
          watch = 'w', -- Watch running workflow
          cancel = 'C', -- Cancel running workflow
          open_browser = '<C-o>', -- Open run/job URL in browser
        },
        logs = { -- Logs buffer
          close = 'q', -- Close the buffer
        },
      },
      -- Optional: configure how buffers are opened
      buffer = {
        history = {
          open_mode = 'tab', -- How to open history buffer: 'tab', 'vsplit', 'split', or 'current' (default: 'tab')
          buflisted = true, -- Whether buffer appears in buffer list (default: true)
          window_options = { -- Window-local options to set (default: {wrap = true})
            wrap = true, -- Enable line wrapping
            number = true, -- Show line numbers
            cursorline = true, -- Highlight current line
          },
        },
        logs = {
          open_mode = 'vsplit', -- How to open logs buffer: 'tab', 'vsplit', 'split', or 'current' (default: 'vsplit')
          buflisted = true, -- Whether buffer appears in buffer list (default: true)
          window_options = { -- Window-local options to set (default: {wrap = false})
            wrap = false, -- Disable line wrapping (better for log files)
            number = false, -- Hide line numbers
          },
        },
      },
    },
  }

  actions.setup(opts)

  vim.keymap.set('n', '<leader>gad', ':GithubActionsDispatch<cr>', { desc = 'GitHub Actions Dispatch Current File' })
  vim.keymap.set(
    'n',
    '<leader>gah',
    ':GithubActionsHistory<cr>',
    { desc = 'GitHub Actions workflow run history for the current workflow file' }
  )
  vim.keymap.set(
    'n',
    '<leader>gap',
    ':GithubActionsHistoryByPR<cr>',
    { desc = 'GitHub Actions Show workflow run history filtered by branch/PR' }
  )
  vim.keymap.set(
    'n',
    '<leader>gaw',
    ':GithubActionsWatch<cr>',
    { desc = 'GitHub Actions Watch running workflow executions in real-time' }
  )
end

return M
