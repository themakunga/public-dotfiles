local M = {}

local codex_buf = nil
local codex_win = nil

local function is_codex_installed()
  return vim.fn.executable('codex') == 1
end

local function toggle()
  if codex_win and vim.api.nvim_win_is_valid(codex_win) then
    vim.api.nvim_win_close(codex_win, true)
    codex_win = nil
    return
  end

  vim.cmd('botright 15split')

  codex_win = vim.api.nvim_get_current_win()

  if codex_buf and vim.api.nvim_buf_is_valid(codex_buf) then
    vim.api.nvim_win_set_buf(codex_win, codex_buf)
  else
    vim.cmd('terminal codex')
    codex_buf = vim.api.nvim_get_current_buf()
  end

  vim.cmd('startinsert')
end

M.plugin = function()
  if not is_codex_installed() then
    vim.notify(
      'Codex CLI no está instalado o no está disponible en el PATH',
      vim.log.levels.ERROR,
      { title = 'Codex' }
    )

    return
  end

  KM.map({
    motion = '<leader>cc',
    cmd = toggle,
    opts = { desc = 'Toggle codex' },
  })
end

return M
