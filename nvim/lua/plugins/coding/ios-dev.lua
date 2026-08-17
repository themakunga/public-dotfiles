-- Archivo: ./lua/plugins/coding/ios-dev.lua
local M = {}

M.plugin = function()
  -- Solo cargamos estos atajos si estamos en un archivo Swift
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'swift',
    callback = function(args)
      local map = vim.keymap.set

      -- Helper para enviar comandos a ToggleTerm
      local function run_in_term(cmd)
        return '<cmd>TermExec cmd="' .. cmd .. '"<cr>'
      end

      -- 🚀 COMPILACIÓN Y TESTING (usando xcbeautify para que se vea limpio)
      map(
        'n',
        '<leader>ib',
        run_in_term('tuist build | xcbeautify'),
        { buffer = args.buf, desc = 'Build Project (Tuist)' }
      )
      map('n', '<leader>it', run_in_term('tuist test | xcbeautify'), { buffer = args.buf, desc = 'Run Tests (Tuist)' })
      map('n', '<leader>ig', run_in_term('tuist generate'), { buffer = args.buf, desc = 'Generate Xcode Proj' })

      -- 📱 GESTIÓN DEL SIMULADOR (Usando el script de Nix que creamos)
      map('n', '<leader>is', run_in_term('ios-sim boot'), { buffer = args.buf, desc = 'Boot Default Simulator' })
      map('n', '<leader>il', run_in_term('ios-sim list'), { buffer = args.buf, desc = 'List Simulators' })
      map('n', '<leader>io', run_in_term('ios-sim open'), { buffer = args.buf, desc = 'Open Simulator UI' })
      map('n', '<leader>iq', run_in_term('ios-sim shutdown'), { buffer = args.buf, desc = 'Shutdown Simulators' })
    end,
  })
end

return M
