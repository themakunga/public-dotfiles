local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/akinsho/toggleterm.nvim', },
  })

  --@module 'toggleterm'
  local ok, toggleterm = pcall(require, 'toggleterm')

  if not ok then
    vim.notify("[CHECK REQUIRE FAILED] toggleterm " .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  --@type toggleterm.SetupOps
  local opts = {
    direction = "float",
    close_on_exit = false,
    persist_mode = true,
    float_opts = {
      border = "curved",
    }
  }

  toggleterm.setup(opts)


  vim.keymap.set('n', '<A-t>', '<cmd>ToggleTerm direction=float<cr>', { desc = "Toggle Terminal" })
  vim.keymap.set('t', '<A-t>', '<C-\\><C-n> :ToggleTerm<CR>', { desc = "Close Terminal" })
end

return M
