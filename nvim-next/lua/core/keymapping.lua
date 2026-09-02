local M = {}

local function mapper(map)
  local mode = map.mode or 'n'
  local motion = map.motion
  local cmd = map.cmd

  if motion == nil or motion == '' then
    Log.error("Keymap error: motion cannot be nil or empty")
    return
  end

  if cmd == nil then
    return
  end

  if cmd == '' then
    Log.error("Keymap error: cmd is emprt for motion '".. motion .. "'", 'keymap')
    return
  end

  local default_opts = {silent = true}
  local opts = vim.tbl_extend('force', default_opts, map.opts or {})

  vim.keymap.set(mode, motion, cmd, opts)

end


local function bulk_mapper(list_keymaps)
  for _, v in ipairs(list_keymaps) do
    mapper(v)
  end
end

M.map = mapper

M.bulk_map = bulk_mapper

return M

