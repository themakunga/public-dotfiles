local M = {}

M.map = function(mode, motion, action, desc, opts)

  opts = opts or {}

  opts.desc = desc

  if opts.silent == nil then
    opts.silent = true
  end

  vim.keymap.set(mode, motion, action, opts)
end

M.bulk_map = function(list)
  for _, item in ipairs(list) do
    M.map(item.mode, item.motion, item.action, item.desc, item.opts)
  end
end

return M
