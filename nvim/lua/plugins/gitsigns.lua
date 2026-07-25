local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  })

  --@module 'gitsigns'
  local ok, gitsigns = pcall(require, 'gitsigns')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] gitsigns ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  --@type gitsigns.SetupOps
  local opts = {
    signcolumn = false,
  }

  gitsigns.setup(opts)

  -- vim.keymap.set('n', '<leader>eo', '<cmd>gitsigns<cr>', {desc = "Open parent directory"})
end

return M
