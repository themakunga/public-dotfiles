local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/stevearc/oil.nvim', },
  })

  --@module 'oil'
  local ok, oil = pcall(require, 'oil')

  if not ok then
    vim.notify("[CHECK REQUIRE FAILED] oil " .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  --@type oil.SetupOps
  local opts = {
    default_file_explorer = false,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    view_options = {
      show_hidden = true,
      natural_order = true,
      is_always_hidden = function(name, _)
        return name == '..' or name == '.git'
      end,
    }
  }

  oil.setup(opts)


  vim.keymap.set('n', '<leader>eo', '<cmd>Oil<cr>', { desc = "Open parent directory" })
end

return M
