local M = {}
local levels = vim.log.levels

local function notify(msg, level, title)
  local opts = {}

  if title then
    opts.title = title
  end

  vim.notify(msg, level, opts)
end

function M.error(msg, title)
  notify(msg, levels.ERROR, title)
end

function M.warn(msg, title)
  notify(msg, levels.WARN, title)
end

function M.info(msg, title)
  notify(msg, levels.INFO, title)
end

function M.debug(msg, title)
  notify(msg, levels.DEBUG, title)
end

function M.trace(msg, title)
  notify(msg, levels.TRACE, title)
end

return M
