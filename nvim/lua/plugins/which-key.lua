local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/folke/which-key.nvim' },
  })

  if not Checker.check('which-key') then
    return
  end

  ---@module 'which-key'
  local wk = require('which-key')

  local opts = {
    preset = 'helix',
    delay = 300,
    icons = {
      mappings = vim.g.have_nerd_font,
      keys = vim.g.have_nerd_font and {} or {
        Up = '<Up> ',
        Down = '<Down> ',
        Left = '<Left> ',
        Right = '<Right> ',
        C = '<C-…> ',
        M = '<M-…> ',
        D = '<D-…> ',
        S = '<S-…> ',
        CR = '<CR> ',
        Esc = '<Esc> ',
        ScrollWheelDown = '<ScrollWheelDown> ',
        ScrollWheelUp = '<ScrollWheelUp> ',
        NL = '<NL> ',
        BS = '<BS> ',
        Space = '<Space> ',
        Tab = '<Tab> ',
        F1 = '<F1>',
        F2 = '<F2>',
        F3 = '<F3>',
        F4 = '<F4>',
        F5 = '<F5>',
        F6 = '<F6>',
        F7 = '<F7>',
        F8 = '<F8>',
        F9 = '<F9>',
        F10 = '<F10>',
        F11 = '<F11>',
        F12 = '<F12>',
      },
    },
    spec = {
      -- Buffers
      { '<leader>b', group = 'Buffers', icon = { icon = '', color = 'yellow' } },

      -- Code / LSP
      { '<leader>c', group = 'Code', mode = { 'n', 'x' }, icon = { icon = '', color = 'green' } },
      { '<leader>cs', group = 'Symbols' },
      { '<leader>cl', group = 'LSP' },

      -- Debug / Bufferline extras
      { '<leader>d', group = 'Debug / Pin', icon = { icon = '', color = 'red' } },

      -- Explorer
      { '<leader>e', group = 'Explorer', icon = { icon = '', color = 'blue' } },

      -- Find (fzf-lua)
      { '<leader>f', group = 'Find', icon = { icon = '󰈞', color = 'yellow' } },

      -- Git
      { '<leader>g', group = 'Git', icon = { icon = '󰊢', color = 'orange' } },
      { '<leader>gb', group = 'Blame / Buffer', icon = { icon = '󰊢', color = 'orange' } },
      { '<leader>gd', group = 'Diff', icon = { icon = '', color = 'orange' } },
      { '<leader>gh', group = 'Hunks', icon = { icon = '', color = 'orange' } },
      { '<leader>gl', group = 'Log', icon = { icon = '󰒙', color = 'orange' } },

      -- AI (CodeCompanion)
      { '<leader>a', group = 'AI', icon = { icon = '󱚦', color = 'cyan' } },

      -- Claude Code
      { '<leader>A', group = 'Claude', icon = { icon = '', color = 'purple' } },

      -- Octo (GitHub)
      { '<leader>o', group = 'GitHub', icon = { icon = '', color = 'blue' } },
      { '<leader>oi', group = 'Issues', icon = { icon = '', color = 'blue' } },
      { '<leader>op', group = 'Pull Requests', icon = { icon = '', color = 'blue' } },

      -- Search
      { '<leader>s', group = 'Search', icon = { icon = '', color = 'yellow' } },

      -- Sops (secrets)
      { '<leader>S', group = 'Sops', icon = { icon = '󰌋', color = 'red' } },

      -- Toggle
      { '<leader>t', group = 'Toggle', icon = { icon = '󰔡', color = 'cyan' } },

      -- Treesitter
      { '<leader>T', group = 'Treesitter', icon = { icon = '', color = 'green' } },

      -- UI
      { '<leader>u', group = 'UI', icon = { icon = '', color = 'cyan' } },

      -- Trouble / Diagnostics
      { '<leader>x', group = 'Diagnostics', icon = { icon = '󰅚', color = 'red' } },

      -- Surround
      { 'gz', group = 'Surround', mode = { 'n', 'v' }, icon = { icon = '', color = 'red' } },
    },
  }

  wk.setup(opts)
end

return M
