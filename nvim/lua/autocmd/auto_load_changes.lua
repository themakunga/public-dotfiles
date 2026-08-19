local M = {}


local map = require('utils.keymap').map
local lmodule = require('utils.load_module')

M.load = function()
  lmodule.start('aucmd', nil)




  lmodule.end('aucmd', nil)
end

return M
