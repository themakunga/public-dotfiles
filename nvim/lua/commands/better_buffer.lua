local M = {}

M.load = function()
  CMD.aucmd('kickstart-highlight-yank', {
    {
      event = 'TextYankPost',
      desc = 'Highlight when yanking (copying) text',
      callback = function()
        vim.hl.on_yank()
      end,
    },
  })

  CMD.aucmd('move-help-windows', { {
    event = 'FileType',
    pattern = 'help',
    command = 'wincmd L',
  } })

  CMD.aucmd('no-auto-comment-next-lin', {
    {
      event = 'FileType',
      callback = function()
        vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })
      end,
    },
  })

  CMD.aucmd('restore-cursor-on-file', {
    {
      event = 'BufReadPost',
      callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
          vim.schedule(function()
            vim.cmd('normal! zz')
          end)
        end
      end,
    },
  })
end

return M
