local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/kdheepak/lazygit.nvim' },
  })

  if not Checker.check('lazygit') then
    return
  end

  KM.map({
    motion = '<leader>glg',
    cmd = function()
      if not package.loaded['lazygit'] then
        M.plugin()
      end
      vim.cmd('LazyGit')
    end,
    opts = { desc = 'Open Lazygit' },
  })
end

return M
