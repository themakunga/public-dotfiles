local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/themakunga/libre-view.nvim', name = 'libreview' },
  })

  local ok, libreview = pcall(require, 'libreview')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] libre-view ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  libreview.setup({
    email = 'nmartinezv@icloud.com',
    password = 'nytfa9-gawtiw-fuFxuk',
    region = 'cl', -- Options: "cl" (LatAm), "eu", "us", "ae"
    update_interval = 300, -- Interval in seconds (5 minutes)
  })
end

return M
