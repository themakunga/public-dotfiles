_G.Loader = require('core.loader')
_G.Log = require('core.logs')
_G.Checker = require('core.checker')
_G.CMD = require('core.cmd')
_G.KM = require('core.keymapping')

Loader('settings.options')
Loader('settings.keymaps')
Loader('commands.init')

local plugins = {
  'snacks_notifier',
  'colorscheme',
  'bufferline',
  'alpha',
  'fzf',
  'oil',
  'notify',
  'lsp',
  'nvim-autopairs',
  'conform',
  'nvim-tree',
  'dressing',
  'mini',
  'nvim-autopairs',
  'mini_hipatterns',
  'sops',
  'sort',
  'tmux_nvim',
  'toggle-term',
  'nvim-treesitter',
  'gitblame',
  'codecompanion',
  'claude-code',
}

vim.pack.add({
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/rcarriga/nvim-notify' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/echasnovski/mini.icons' },
  { src = 'https://github.com/MunifTanjim/nui.nvim' },
  { src = 'https://github.com/folke/snacks.nvim' },
})

for _, plugin in ipairs(plugins) do
  Loader('plugins.' .. plugin)
end
