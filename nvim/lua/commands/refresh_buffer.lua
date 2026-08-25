local M = {}

local reader_events = {
  'FocusGained',
  'BufEnter',
  'CursorHold',
  'CursorHoldI',
  'TermClose',
  'TermLeave',
}

local read_file = {
  {
    event = reader_events,
    callback = function()
      if vim.fn.mode() == 'c' or vim.bo.buftype ~= '' then
        return
      end
      vim.cmd('checktime')
    end,
  },
  {
    event = 'FileChangedShellPost',
    callback = function(ev)
      local buffer = vim.api.nvim_buf_get_name(ev.buf)
      Log.info(string.format('Reloaded: %s', vim.fn.fnamemodify(buffer, ':t')))
    end,
  },
}

M.load = function()
  vim.opt.autoread = true

  CMD.aucmd('AutoRead', read_file)

  KM.bulk_map({
    {
      mode = 'n',
      motion = '<leader>brr',
      cmd = function()
        vim.cmd('edit!')
        Log.info('Current buffer reloaded')
      end,
      opts = { desc = 'Force reload current buffer' },
    },
    {
      mode = 'n',
      motion = '<leader>brc',
      cmd = function()
        vim.cmd('checktime')
      end,
      opts = { desc = 'Verify if buffer has changes in other app' },
    },
  })
end

return M
