local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/sQVe/sort.nvim' },
  })

  local ok, sort = pcall(require, 'Sort')
  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] Sort ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  sort.setup()
end

return M
