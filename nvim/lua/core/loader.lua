local M = {}

local log = vim.log.levels

M.load = function(module_name)
  local ok, mod = pcall(require, module_name)

  if not ok then
    vim.notify("Error loading file: " .. module_name .. "\n" .. tostring(mod), log.ERROR)
    return
  end

  if type(mod) ~= "table" then
    return
  end

  local lifecycle_methods = {"init", "load", "plugin"}

  for _, method in ipairs(lifecycle_methods) do
    if type(mod[method]) == "function" then
      vim.notify(string.format("Starting: [%s] -> %s()", module_name, method), log.DEBUG)
      local success, err = pcall(mod[method])

      if success then
        vim.notify(string.format("End, [%s] -> %s()", module_name, method), log.DEBUG)
      else
        vim.notify(string.format("Error: [%s] -> %s()", module_name, method), log.ERROR
      end
    end
  end
end


return M
