local M = {}

M.load = function()
  Loader('commands.better_buffer')
  Loader('commands.healthchecks')
  Loader('commands.ios-development')
  Loader('commands.pack_functions')
  Loader('commands.refresh_buffer')
end

return M
