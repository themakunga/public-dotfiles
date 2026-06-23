-- common packages to use and dont re declare it

vim.pack.add({
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/rcarriga/nvim-notify' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/nvim-mini/mini.icons' },
  { src = 'https://github.com/MunifTanjim/nui.nvim' },
  { src = 'https://github.com/rcarriga/nvim-notify' },

  -- {src = ""},
})

-- ui
require('plugins.tokyonight').plugin()
require('plugins.snacks').plugin()
require('plugins.bufferline').plugin()
require('plugins.lualine').plugin()
require('plugins.whichkey').plugin()
-- require('plugins.spell').plugin()
require('plugins.bafa').plugin()
-- require('plugins.neominimap').plugin()

-- navigation
require('plugins.oil').plugin()
require('plugins.nvimtree').plugin()
require('plugins.telescope').plugin()

-- lsp
require('plugins.trouble').plugin()
require('plugins.lsp').plugin()
require('plugins.treesitter').plugin()
-- require('plugins.dap').plugin()
require('plugins.sort').plugin()

-- git
require('plugins.gitsigns').plugin()
require('plugins.lazygit').plugin()
require('plugins.gitblame').plugin()

-- format
require('plugins.log-highlight').plugin()
require('plugins.autoclose').plugin()

-- terminal
require('plugins.toggle-term').plugin()

-- markdown
require('plugins.rendermarkdown').plugin()
require('plugins.markdown-toc').plugin()
require('plugins.mardownpdf').plugin()

require('plugins.sops').plugin()

require('plugins.github-actions').plugin()
require('plugins.octo').plugin()
require('plugins.tuxedo').plugin()
-- messages
require('plugins.noice').plugin()
require('plugins.comment').plugin()

require('plugins.accesibility').plugin()

-- fallando

-- require('plugins.package').plugin()
