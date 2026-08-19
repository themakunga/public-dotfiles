local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/IogaMaster/tuxedo.nvim' },
  })

  local ok, tuxedo = pcall(require, 'tuxedo')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] tuxedo ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local opts = {
    create_todo_file = true,
    width_ratio = 0.95,
    height_ratio = 0.80,
  }

  tuxedo.setup(opts)

  vim.keymap.set('n', '<leader>T', ':Tuxedo<cr>', { desc = 'Open tuxedo' })
end

return M
