local M = {}

M.cwd_is_under = function(roots)
  local cwd = vim.uv.cwd()

  if not cwd then
    return false
  end

  for _, root in ipairs(roots) do
    local expanded = vim.fs.normalize(root)
    if cwd == expanded or cwd:sub(1, #expanded + 1) == expanded .. '/' then
      return true
    end
  end

  return false
end

M.is_grainger = function()
  return M.cwd_is_under({ '~/Projects/Grainger' })
end

return M
