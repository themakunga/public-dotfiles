local M = {}

local function create_augroup(name, autocmds)
  local grp = vim.api.nvim_create_augroup(name, { clear = true })

  for _, cmd in ipairs(autocmds) do
    local event = cmd.event or cmd[1]
    cmd.event = nil
    cmd[1] = nil

    cmd.group = grp
    if not cmd.buffer and not cmd.buf then
      cmd.pattern = cmd.pattern or '*'
    end

    vim.api.nvim_create_autocmd(event, cmd)
  end
end

local function create_user_command(name, fn, opts)
  if name == '' then
    Log.error('The user command must be named')
    return
  end

  if type(fn) ~= 'function' and type(fn) ~= 'string' then
    Log.error('The parameter is not a function or string in command: ' .. name)
    return
  end

  opts = opts or {}

  vim.api.nvim_create_user_command(name, fn, opts)
end


local function create_auto_namespace(name)
  if name == "" then
    Log.error("namespace coult not be empty")
  end

  vim.api.nvim_create_namespace(name)
end


M.aucmd = create_augroup

M.usrcmd = create_user_command

M.auns = create_auto_namespace

return M
