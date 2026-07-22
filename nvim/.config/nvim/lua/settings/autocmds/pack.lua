local M = {}

M.load = function()
  -- prompt delete installed package
  vim.api.nvim_create_user_command('PackDeletePackage', function()
    local pkg = vim.fn.input('Input Package Name as is in lockfile: ')

    if pkg and pkg ~= '' then
      local ok, _ = pcall(require, pkg)
      if not ok then
        vim.notify('Package ' .. pkg .. ' does not exists or the name is wrong', vim.log.level.WARN)
      else
        vim.pack.del({ pkg })
        vim.notify(
          'Package ' .. pkg .. ' deleted successfully, remember delete all references in ./lua/plugins/init.lua',
          vim.log.levels.INFO
        )
      end
    end
  end, {})
  vim.keymap.set('n', '<leader>PD', ':PackDeletePackage<cr>', { desc = 'Delete instaled package' })

  -- prompt update package
  vim.api.nvim_create_user_command('PackUpdatePackage', function()
    local pkg = vim.fn.input('Update package *empty for a full update: ')

    if pkg and pkg ~= '' then
      vim.pack.update({ pkg })
      vim.notify('Package ' .. pkg .. ' updated successfully', vim.log.levels.INFO)
    else
      vim.pack.update()
    end
  end, {})
  vim.keymap.set('n', '<leader>PU', ':PackUpdatePackage', { desc = 'Update a single or multiple packages' })
end

return M
