local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/numToStr/Comment.nvim' },
    { src = 'https://github.com/JoosepAlviste/nvim-ts-context-commentstring' },
  })

  ---@module 'comment'
  local ok, Comment = pcall(require, 'comment')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] Comment ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  ---@diagnostic disable-next-line: redefined-local
  local ok_ts_context_commentstring, ts_context_commentstring = pcall(require, 'ts_context_commentstring')

  if not ok_ts_context_commentstring then
    vim.notify('[CHECK REQUIRE FAILED] ts comment string' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local opts = {
    pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
    toggler = {
      ---Line-comment toggle keymap
      line = 'gcc',
      ---Block-comment toggle keymap
      block = 'gbc',
    },
  }

  Comment.setup(opts)

  -- vim.keymap.set('n', '<leader>eo', '<cmd>comment<cr>', {desc = "Open parent directory"})
end

return M
