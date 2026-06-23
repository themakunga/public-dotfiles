local M = {}

M.plugin = function()
  vim.pack.add({
    { src = "https://github.com/folke/tokyonight.nvim", },
  })


local ok, tokyonight = pcall(require, 'tokyonight')
if not ok then
  vim.notify("[CHECK REQUIRE FAILED] tokyonight "..debug.getinfo(2).source, vim.log.levels.WARN)
  return
end


local opts = {
  style = "storm",
    transparent = true,
    styles = {
      floats = "transparent",
      sidebars = "transparent",
    },
  }

  tokyonight.setup(opts)

  vim.cmd("colorscheme tokyonight")

end

return M
