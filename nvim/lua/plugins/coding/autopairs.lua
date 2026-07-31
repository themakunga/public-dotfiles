local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/windwp/nvim-autopairs' },
  })

  ---@module 'nvim-autopairs'
  local ok, autopairs = pcall(require, 'nvim-autopairs')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] nvim-autopairs ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  -- Bracket/quote pairing while typing. Completion-driven bracket insertion
  -- (adding `()` after accepting a function) is handled by blink.cmp itself.
  local opts = {}

  autopairs.setup(opts)
end

return M
