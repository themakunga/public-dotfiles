local M = {}

local function create_augroup(name, autocmds)
  if not name or name == '' then
    Log.error('Autocmd group name cannot be empty')
    return
  end

  local group = vim.api.nvim_create_augroup(name, {
    clear = true,
  })

  for _, autocmd in ipairs(autocmds) do
    local cmd = vim.deepcopy(autocmd)

    local event = cmd.event or cmd[1]

    cmd.event = nil
    cmd[1] = nil

    if not event then
      Log.error('Autocmd event cannot be empty: ' .. name)
      return
    end

    cmd.group = group

    -- Allow `buf` as an alias if you want to use it in your config.
    if cmd.buf then
      cmd.buffer = cmd.buf
      cmd.buf = nil
    end

    if not cmd.buffer then
      cmd.pattern = cmd.pattern or '*'
    end

    vim.api.nvim_create_autocmd(event, cmd)
  end
end

local function create_user_command(name, fn, opts)
  if not name or name == '' then
    Log.error('The user command must be named')
    return
  end

  if type(fn) ~= 'function' and type(fn) ~= 'string' then
    Log.error('The parameter is not a function or string in command: ' .. name)
    return
  end

  vim.api.nvim_create_user_command(name, fn, opts or {})
end

local function create_auto_namespace(name)
  if not name or name == '' then
    Log.error('Namespace cannot be empty')
    return
  end

  return vim.api.nvim_create_namespace(name)
end

M.aucmd = create_augroup
M.usrcmd = create_user_command
M.auns = create_auto_namespace

return M
