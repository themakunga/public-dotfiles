local M = {}

M.init = function()
  require('settings.options').load()
  require('settings.keymaps').load()
end

return M
