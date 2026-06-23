local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/catgoose/nvim-colorizer.lua', },
  })

  --@module 'colorizer'
  local ok, colorizer = pcall(require, 'colorizer')

  if not ok then
    vim.notify("[CHECK REQUIRE FAILED] colorizer " .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  --@type colorizer.SetupOps
  local opts = {
    filetypes = { "*" },
    user_default_options = {
      xterm = true,
      mode = "background"
    },

  }

  colorizer.setup(opts)


  -- vim.keymap.set('n', '<leader>eo', '<cmd>colorizer<cr>', {desc = "Open parent directory"})
end

return M
