local M = {}

local codex_buf = nil
local codex_win = nil

local function is_codex_installed()
  return vim.fn.executable('codex') == 1
end

local function get_window_config()
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.80)

  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

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
    vim.api.nvim_win_close(codex_win, false)
    codex_win = nil
    return
  end

  if codex_buf and vim.api.nvim_buf_is_valid(codex_buf) then
    open_window()
  else
    codex_buf = vim.api.nvim_create_buf(false, true)

    open_window()
    vim.keymap.set('t', '<C-g>', '<C-\\><C-n><cmd>Codex<CR>', {
      desc = 'Hide Codex terminal',
      buffer = codex_buf,
    })

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
  end

  vim.cmd('startinsert')
end

M.plugin = function()
  if not is_codex_installed() then
    Log.error('Codex not installed')
    return
  end

  CMD.usrcmd('Codex', toggle, { desc = 'Toggle Codex terminal' })

  KM.map({
    motion = '<leader>cc',
    cmd = toggle,
    opts = {
      desc = 'Show Codex support',
    },
  })
end

return
