local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/echasnovski/mini.nvim' },
  })

  if not Checker.check({ 'mini.ai', 'mini.surround', 'mini.move' }) then
    return
  end

  require('mini.ai').setup({ n_lines = 500 })
  require('mini.surround').setup({
    mappings = {
      add = 'gsa',
      delete = 'gsd',
      find = 'gsf',
      find_left = 'gsF',
      highlight = 'gsh',
      replace = 'gsr',
      update_n_lines = 'gsn',
    },
  })
  require('mini.move').setup({
    mappings = {
      left = 'H',
      right = 'L',
      down = 'J',
      up = 'K',
      line_left = '',
      line_right = '',
      line_down = '',
      line_up = '',
    },
  })
end

return M
