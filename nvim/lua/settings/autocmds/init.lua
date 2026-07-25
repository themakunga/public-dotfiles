local M = {}

M.init = function()
  require('settings.autocmds.autoread').load()
  require('settings.autocmds.buffer').load()
  require('settings.autocmds.checkhealth').load()
  require('settings.autocmds.pack').load()
end

return M
