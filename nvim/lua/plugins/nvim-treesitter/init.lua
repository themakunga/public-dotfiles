local M = {}

local config = require('plugins.nvim-treesitter.config')

local function setup_treesitter()
  local treesitter = require('nvim-treesitter')

  if type(treesitter.install) ~= 'function' then
    Log.error('nvim-treesitter legacy branch detected. ' .. 'Switch to main with :packupdate nvim-treesitter')
    return false
  end

  treesitter.setup({})

  treesitter.install(config.parsers)

  require('plugins.nvim-treesitter.filetypes').setup()
  require('plugins.nvim-treesitter.features').setup()
  require('plugins.nvim-treesitter.updates').setup()

  return true
end

local function setup_context()
  require('treesitter-context').setup(config.context)
end

local function setup_keymaps()
  KM.bulk_map({
    {
      motion = '<leader>Tu',
      cmd = '<cmd>TSUpdate<CR>',
      opts = {
        desc = 'Treesitter: Update parsers',
      },
    },
    {
      motion = '<leader>Ti',
      cmd = '<cmd>TreesitterCheckUpdates<CR>',
      opts = {
        desc = 'Treesitter: Check parser updates',
      },
    },
    {
      motion = '<leader>ut',
      cmd = '<cmd>TSContext toggle<CR>',
      opts = {
        desc = 'Toggle Treesitter Context',
      },
    },
  })
end

M.plugin = function()
  vim.pack.add({
    {
      src = 'https://github.com/nvim-treesitter/nvim-treesitter',
      version = 'main',
    },
    {
      src = 'https://github.com/nvim-treesitter/nvim-treesitter-context',
    },
  })

  if not Checker.check({
    'nvim-treesitter',
    'treesitter-context',
  }) then
    return
  end

  if not setup_treesitter() then
    return
  end

  setup_context()
  setup_keymaps()
end

return M
