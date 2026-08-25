local M = {}

M.load = function()
  CMD.aucmd('ios-development', {
    {
      event = 'FileType',
      pattern = 'swift',
      callback = function(args)
        local function run_in_term(cmd)
          return '<cmd>TermExec cmd="' .. cmd .. '"<cr>'
        end

        local function opts_cont(desc)
          return { buffer = args.buf, desc = desc }
        end

        KM.bulk_map({
          {
            motion = '<leader>ib',
            cmd = run_in_term('tuist build | xcbeautify'),
            opts = opts_cont('Build Project (Tuist)'),
          },
          {
            motion = '<leader>it',
            cmd = run_in_term('tuist test | xcbeautify'),
            opts = opts_cont('Generate Xcode Proj'),
          },
          { motion = '<leader>ig', cmd = run_in_term('tuist generate'), opts = opts_cont('Generate Xcode Proj') },
          { motion = '<leader>is', cmd = run_in_term('ios-sim boot'), opts = opts_cont('Boot Default Simulator') },
          { motion = '<leader>il', cmd = run_in_term('ios-sim list'), opts = opts_cont('List Simulators') },
          { motion = '<leader>io', cmd = run_in_term('ios-sim open'), opts = opts_cont('Open Simulator UI') },
          { motion = '<leader>iq', cmd = run_in_term('ios-sim shutdown'), opts = opts_cont('Shutdown Simulators') },
        })
      end,
    },
  })
end

return M
