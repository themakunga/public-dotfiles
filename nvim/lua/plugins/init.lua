local M = {}

local plugins = {
  'snacks_notifier',
  'colorscheme',
  'bufferline',
  'alpha',
  'fzf',
  'oil',
  'notify',
  'lsp',
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
}

M.init = function()
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
end

return M
