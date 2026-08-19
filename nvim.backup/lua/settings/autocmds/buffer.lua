local M = {}

M.load = function()
  -- Highlight yanked text
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
      vim.hl.on_yank()
    end,
  })

  -- open help on vertical split
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'help',
    command = 'wincmd L',
  })

  -- resize and keep proportion
  -- vim.api.nvim_create_autocmd("VimResized", {
  --   command = "wincmd =",
  -- })

  -- no continue comments on next line
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('no-auto-comment-next-line', {}),
    callback = function()
      vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })
    end,
  })

  -- restore cursor on file position in prev edition
  vim.api.nvim_create_autocmd('BufReadPost', {
    callback = function(args)
      local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
      local line_count = vim.api.nvim_buf_line_count(args.buf)
      if mark[1] > 0 and mark[1] <= line_count then
        vim.schedule(function()
          vim.cmd('normal! zz')
        end)
      end
    end,
  })
end

return M
