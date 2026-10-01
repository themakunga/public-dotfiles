local M = {}

local codex_buf = nil
local codex_win = nil

local function is_codex_installed()
  return vim.fn.executable('codex') == 1
end

local function get_window_config()
  local width  = math.floor(vim.o.columns * 0.95)
  local height = math.floor(vim.o.lines   * 0.3)
  local row    = math.floor(vim.o.lines   * 0.9)
  local col    = math.floor(vim.o.columns * 0.025)
  return {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Codex ',
    title_pos = 'center',
  }
end

local function open_window()
  codex_win = vim.api.nvim_open_win(codex_buf, true, get_window_config())
  vim.api.nvim_set_option_value('winhl', 'Normal:NormalFloat,FloatBorder:FloatBorder', { win = codex_win })
end

local function toggle()
  if codex_win and vim.api.nvim_win_is_valid(codex_win) then
    -- ponytail: hide preserva el buffer/proceso; close podría destruirlo
    vim.api.nvim_win_hide(codex_win)
    codex_win = nil
    return
  end

  if codex_buf and vim.api.nvim_buf_is_valid(codex_buf) then
    open_window()
    vim.cmd('startinsert')
    return
  end

  codex_buf = vim.api.nvim_create_buf(false, true)
  open_window()

  -- Keymaps buffer-local
  local buf_opts = { buffer = codex_buf, silent = true }
  vim.keymap.set('t', '<Esc>',  '<C-\\><C-n>',                    vim.tbl_extend('force', buf_opts, { desc = 'Normal mode' }))
  vim.keymap.set('n', 'x',     toggle,                            vim.tbl_extend('force', buf_opts, { desc = 'Ocultar Codex' }))
  vim.keymap.set('n', 'q',     toggle,                            vim.tbl_extend('force', buf_opts, { desc = 'Ocultar Codex' }))
  vim.keymap.set('t', '<C-g>', '<C-\\><C-n><cmd>Codex<cr>',       vim.tbl_extend('force', buf_opts, { desc = 'Ocultar Codex (terminal mode)' }))

  vim.fn.jobstart({ 'codex' }, {
    term = true,
    on_exit = function()
      if codex_win and vim.api.nvim_win_is_valid(codex_win) then
        vim.api.nvim_win_close(codex_win, true)
      end
      codex_buf = nil
      codex_win = nil
    end,
  })

  vim.cmd('startinsert')
end

M.plugin = function()
  if not is_codex_installed() then
    Log.error('Codex not installed')
    return
  end

  CMD.usrcmd('Codex', toggle, { desc = 'Toggle Codex terminal' })

  KM.map({
    motion = '<leader>AXt',
    cmd = toggle,
    opts = { desc = 'Toggle Codex' },
  })
end

return M
