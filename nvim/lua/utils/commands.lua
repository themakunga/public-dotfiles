local M = {}

M.augroup_opts = {
  clear = true
};

M.augroup = function(group_name, opts)
  M.augroup_opts = vim.tbl_deep_extend("force", M.augroup_opts, opts or {})

  if group_name == "" || type(group_name) != "string" then
    vim.notify("[AUTOGROUP - create]: the group name must be a valid string" .. debug.getinfo(2).debug, vim.log.levels.ERROR)
    return
  end

  local result = vim.api.nvim_create_augroup(group_name, M.augroup_opt)

  return result;
end

M.autocmd = function(group, cmds)

  for _, cmd in ipairs(cmds) do
    local events = cmd.event or cmd[1]
    cmd.event = nil
    cmd[1] = nil

    cmd.group = group
    cmd.pattern = cmd.pattern or "*"


    vim.api.nvim_create_autocmd(events, cmd)
  end

end

M.usercmd = function(cmds)

  for _, cmd in ipairs(cmds) do
    local name = cmd.name or cmd[1]
    local action = cmd.action or cmd[2]

    cmd.name = nil
    cmd.action = nil
    cmd[1] = nil
    cmd[2] = nil

    local opts = cmd or {}

    vim.api.nvim_create_user_command(name, action, opts)
  end
end

return M
