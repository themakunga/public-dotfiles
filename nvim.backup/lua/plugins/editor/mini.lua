local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/echasnovski/mini.nvim' },
  })

  ---@module 'mini.ai'
  local ok_ai, mini_ai = pcall(require, 'mini.ai')
  if not ok_ai then
    vim.notify('[CHECK REQUIRE FAILED] mini.ai ' .. debug.getinfo(2).source, vim.log.levels.WARN)
  else
    mini_ai.setup({ n_lines = 500 })
  end

  ---@module 'mini.surround'
  local ok_surround, mini_surround = pcall(require, 'mini.surround')
  if not ok_surround then
    vim.notify('[CHECK REQUIRE FAILED] mini.surround ' .. debug.getinfo(2).source, vim.log.levels.WARN)
  else
    mini_surround.setup({
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
  end

  ---@module 'mini.move'
  local ok_move, mini_move = pcall(require, 'mini.move')
  if not ok_move then
    vim.notify('[CHECK REQUIRE FAILED] mini.move ' .. debug.getinfo(2).source, vim.log.levels.WARN)
  else
    mini_move.setup({
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
end

return M
