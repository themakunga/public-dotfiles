local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/ekickx/clipboard-image.nvim' },
  })

  if not Checker.check('clipboard-image') then
    return
  end

  -- Upstream still requires the legacy health module.
  package.loaded.health = package.loaded.health
    or {
      report_start = vim.health.start,
      report_ok = vim.health.ok,
      report_error = vim.health.error,
    }
  require('clipboard-image').setup({
    default = {
      img_dir = function()
        local root = vim.fs.root(0, '.obsidian')
        return root and vim.fs.joinpath(root, 'assets') or 'img'
      end,
      img_dir_txt = function()
        local root = vim.fs.root(0, '.obsidian')
        if not root then
          return 'img'
        end
        local relative = vim.fs.relpath(root, vim.fn.expand('%:p:h'))
        if relative == '.' then
          return 'assets'
        end
        return relative:gsub('[^/]+', '..') .. '/assets'
      end,
    },
  })
end

return M
