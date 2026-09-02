local M = {}

local function update_packages()
  local pkg = vim.fn.input('Update package *empty for a full update: ')

  if pkg and pkg ~= '' then
    vim.pack.update({ pkg })
    vim.notify('Package ' .. pkg .. ' updated successfully', vim.log.levels.INFO)
  else
    vim.pack.update()
  end
end

local function delete_package()
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
end


M.init = function()
  CMD.usrcmd('PackagesUpdate', update_packages)
  CMD.usrcmd('PackagesDelete', delete_package)

  KM.bulk_map({
    {
      mode = 'n',
      motion = '<leader>Pd',
      cmd = ':PackDeletePackage<CR>',
      opts = { desc = 'Delete instaled package' },
    },
    {
      mode = 'n',
      motion = '<leader>Pu',
      cmd = ':PackUpdatePackage<CR>',
      opts = { desc = 'Update a single or multiple packages' },
    },
  })
end

return M
