local M = {}

local ai_buf = nil
local ai_win = nil
local ai_job = nil

local function get_window_config()
  local width = math.floor(vim.o.columns * 0.95)
  local height = math.floor(vim.o.lines * 0.3)

  return {
    relative = 'editor',
    width = width,
    height = height,
    row = math.max(0, vim.o.lines - height - 4),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Local AI ',
    title_pos = 'center',
  }
end

local function is_running()
  return ai_job ~= nil and vim.fn.jobwait({ ai_job }, 0)[1] == -1
end

local function hide()
  if ai_win and vim.api.nvim_win_is_valid(ai_win) then
    vim.api.nvim_win_hide(ai_win)
  end

  ai_win = nil
end

local function open_window()
  ai_win = vim.api.nvim_open_win(ai_buf, true, get_window_config())

  vim.api.nvim_set_option_value('winhl', 'Normal:NormalFloat,FloatBorder:FloatBorder', { win = ai_win })

  vim.cmd('startinsert')
end

local function toggle(model)
  if ai_win and vim.api.nvim_win_is_valid(ai_win) then
    hide()
    return
  end

  if ai_buf and vim.api.nvim_buf_is_valid(ai_buf) and is_running() then
    open_window()
    return
  end

  if vim.fn.executable('ai') ~= 1 then
    Log.error('Local AI is not installed')
    return
  end

  local root = vim.fs.root(0, { '.git' }) or vim.fn.getcwd()

  ai_buf = vim.api.nvim_create_buf(false, true)

  vim.bo[ai_buf].bufhidden = 'hide'

  open_window()

  local command = { 'ai' }

  if model then
    command = { 'opencode', '--model', 'local/' .. model }
  end

  ai_job = vim.fn.jobstart(command, {
    term = true,
    cwd = root,

    on_exit = function()
      vim.schedule(function()
        hide()

        if ai_buf and vim.api.nvim_buf_is_valid(ai_buf) then
          vim.api.nvim_buf_delete(ai_buf, { force = true })
        end

        ai_job = nil
        ai_buf = nil
      end)
    end,
  })

  local opts = {
    buffer = ai_buf,
    silent = true,
  }

  vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', opts)

  vim.keymap.set('n', 'q', hide, opts)
  vim.keymap.set('n', 'x', hide, opts)

  vim.keymap.set('t', '<C-g>', '<C-\\><C-n><cmd>LocalAI<cr>', opts)
end

local function select_model()
  if is_running() then
    vim.notify('Close the current Local AI session first', vim.log.levels.WARN)
    return
  end

  vim.ui.select({
    'fast',
    'coder',
    'reasoning',
  }, {
    prompt = 'Select local model',
  }, function(model)
    if model then
      toggle(model)
    end
  end)
end

local function stop()
  if is_running() then
    vim.fn.jobstop(ai_job)
  end
end

M.plugin = function()
  if vim.fn.executable('ai') ~= 1 then
    return
  end

  CMD.usrcmd('LocalAI', function()
    toggle()
  end, {
    desc = 'Toggle Local AI terminal',
  })

  CMD.usrcmd('LocalAIModel', select_model, {
    desc = 'Select Local AI model',
  })

  CMD.usrcmd('LocalAIStop', stop, {
    desc = 'Stop Local AI session',
  })

  KM.bulk_map({
    {
      mode = 'n',
      motion = '<leader>ALt',
      cmd = '<cmd>LocalAI<cr>',
      opts = { desc = 'Toggle Local AI' },
    },
    {
      mode = 'n',
      motion = '<leader>ALm',
      cmd = select_model,
      opts = { desc = 'Select local model' },
    },
    {
      mode = 'n',
      motion = '<leader>ALx',
      cmd = stop,
      opts = { desc = 'Stop Local AI' },
    },
  })
end

return M
