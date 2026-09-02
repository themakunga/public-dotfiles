local M = {}

local function check(path)
  if type(path) == 'string' then
    path = { path }
  end

  for _, p in pairs(path) do
    local ok, _ = pcall(require, p)

    if not ok then
      Log.warn('Checker - plugin: Require failed ' .. p .. '.' .. debug.getinfo(2).source)
      return false
    end
  end
  return true
end

M.check = check

return M
