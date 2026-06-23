local M = {}

M.buffer_name = function(namespace)
  return 'LOG-' .. namespace
end

M.find_log_buffer = function(buffer_name)
  local bufferlist = vim.api.nvim_list_bufs()

  for _, buf_num in ipairs(bufferlist) do
    local name = vim.fn.bufname(buf_num)

    if name == buffer_name then
      return buf_num
    end
  end
end

M.create_logger = function(namespace)
  local opts = { namespace = namespace }
  local logging_func_for = function(level)
    return function(msg)
      M.log(msg, level, opts)
    end
  end

  return {
    trace = logging_func_for(vim.log.levels.TRACE),
    debug = logging_func_for(vim.log.levels.DEBUG),
    info = logging_func_for(vim.log.levels.INFO),
    warn = logging_func_for(vim.log.levels.WARN),
    error = logging_func_for(vim.log.levels.ERROR),
  }
end

M.log = function(message, level, options)
  ---@diagnostic disable-next-line
  local options = options or {}

  local namespace = options.namespace or 'default'
  local buffername = M.buffer_name(namespace)
  local buffer = M.find_log_buffer(buffername)

  if not buffer or buffer == nil then
    buffer = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(buffer, buffername)
  end

  local lvl_str = 'INFO'

  for l, i in pairs(vim.log.levels) do
    if level == i then
      lvl_str = l
    end
  end

  if type(message) == 'string' then
    message = { message }
  end

  message = vim.tbl_map(function(line)
    return vim.split(line, '\n')
  end, message)

  message = vim.iter(message):flatten(1):totable()

  local complete_message = vim.tbl_map(function(line)
    return '[' .. lvl_str .. ']' .. line
  end, message)

  vim.api.nvim_buf_set_lines(buffer, -1, -1, true, complete_message)
end

return M
