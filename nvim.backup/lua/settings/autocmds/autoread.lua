local M = {}

M.load = function()
  -- enable autoread
  vim.opt.autoread = true

  local grp = vim.api.nvim_create_augroup('AutoRead', { clear = true })

  local events = {
    'FocusGained',
    'BufEnter',
    'CursorHold',
    'CursorHoldI',
    'TermClose',
    'TermLeave',
  }
  vim.api.nvim_create_autocmd(events, {
    group = grp,
    pattern = '*',
    callback = function()
      if vim.fn.mode() == 'c' or vim.bo.buftype ~= '' then
        return
      end
      vim.cmd('checktime')
    end,
  })

  vim.api.nvim_create_autocmd('FileChangedShellPost', {
    group = grp,
    pattern = '*',
    callback = function(ev)
      local buffer = vim.api.nvim_buf_get_name(ev.buf)

      vim.notify(string.format('Reloaded: %s', vim.fn.fnamemodify(buffer, ':t')), vim.log.levels.INFO)
    end,
  })

  vim.keymap.set('n', '<leader>brr', function()
    vim.cmd('edit!') -- Fuerza la recarga del archivo
    vim.notify('Current buffer reloaded', vim.log.levels.INFO)
  end, { desc = 'Force reload current buffer' })

  vim.keymap.set('n', '<leader>brc', function()
    vim.cmd('checktime')
  end, { desc = 'Verify if buffer is changed outside' })
end

return M
