local M = {};

M.check = function(require_name)
  if type(require_name) != 'string' then
    vim.notify("[UTILS - Checker - failed]: you put a not valid parameter to check, you must use a string" .. debug.getinfo(2).source, vim.log.levels.ERROR)
    return false
  end

  local ok, _ = pcall(require, require_name)
  if not ok then
    vim.notify("[CHECKER - require failed ]".. require_name .. ". " .. debug.getinfo(2).source, vim.log.levels.WARN)
    return false
  end

  return true
end

return M
