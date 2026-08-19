local M = {}

local lvl = vim.log.levels

M.start = function(title, message)
  vim.notify('[MODULE - load start] ' .. lvl.DEBUG, {title = title})
end

M.end = function(title, message)
  vim.notify('[MODULE - load - end] '.. message, lvl.DEBUG, {title = title})
end

return M

