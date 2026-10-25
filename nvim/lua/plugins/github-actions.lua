local M = {}

M.plugin = function()
  if not Checker.check('gama-tui') then return end

  local Terminal = require('toggleterm.terminal').Terminal
  local gama = Terminal:new({
    cmd = 'gama-tui',
    direction = 'float',
    close_on_exit = true,
    float_opts = {
      border = 'rounded',
      width = math.floor(vim.o.columns * 0.92),
      height = math.floor(vim.o.lines * 0.88),
    },
  })
  KM.map({
    motion = '<leader>oga',
    cmd = function() gama:toggle() end,
    opts = { desc = 'GitHub Actions monitor (gama-tui)' },
  })
end

return M
