local M = {}

M.dapKeymapsAttached = function(buffer)
  local map = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = buffer, desc = 'DAP: ' .. desc })
  end

  local dap = require('dap')

  map('<leader>dt', dap.toggle_breakpoint, 'Toggle break')
  map('<leader>dc', dap.continue, 'Continue')
  map('<leader>dr', dap.repl.open, 'Inspect')
  map('<leader>dk', dap.terminate, 'Kill')

  map('<leader>dso', dap.step_over, 'Step over')
  map('<leader>dsi', dap.step_into, 'Step into')
  map('<leader>dsu', dap.step_out, 'Step out')
  map('<leader>dl', dap.run_last, 'Run last')

  map('<leader>dv', ':DapViewToggle<cr>', 'Toggle debugger view')
  map('<leader>dw', ':DapViewWatch<cr>', 'Debugger watch view')
end

return M
