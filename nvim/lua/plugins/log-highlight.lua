local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/fei6409/log-highlight.nvim' },
  })

  --@module 'loghighlight'
  local ok, loghighlight = pcall(require, 'log-highlight')

  if not ok then
    vim.notify("[CHECK REQUIRE FAILED] loghighlight " .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  --@type loghighlight.SetupOps
  local opts = {
    pattern = {
      ".*%.log%..*",
      ".*%.log%d+",
      ".*%.log%d+%.?gz?",
    },

  }

  loghighlight.setup(opts)


  -- vim.keymap.set('n', '<leader>eo', '<cmd>loghighlight<cr>', {desc = "Open parent directory"})
end

return M
