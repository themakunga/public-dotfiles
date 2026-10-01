local M = {}

local opts = {
  tuxedo_cmd = 'tuxedo',
  terminal = {
    width = 0.85,
    height = 0.7,
  },
  command = 'Tuxedo',
  todo_file = {
    create_if_not_exists = true,
    file_name = 'todo.txt',
  },
}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/RVxLab/tuxedo.nvim', version = vim.version.range('^1.0.0') },
  })

  if not Checker.check({ 'snacks', 'tuxedo' }) then
    return
  end

  require('tuxedo').setup(opts)

  KM.map({
    mode = 'n',
    motion = '<leader>Tt',
    cmd = ':Tuxedo<cr>',
    opts = { desc = 'Toggle Tuxedo' },
  })
end

return M
