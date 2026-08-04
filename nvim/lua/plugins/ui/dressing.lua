local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/stevearc/dressing.nvim' },
  })

  ---@module 'dressing'
  local ok, dressing = pcall(require, 'dressing')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] dressing ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  -- Kept only for vim.ui.input; vim.ui.select is handled by fzf-lua.
  local opts = {}

  dressing.setup(opts)
end

return M
