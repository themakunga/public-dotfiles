local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/stevearc/oil.nvim' },
  })

  if not Checker.check("oil") then
    return
  end

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
    },
  }


  require("oil").setup(opts)

  KM.map({
    mode = "n",
    motion = "<leader>eo",
    cmd = "<CMD>Oil<CR>",
    opts = {desc = "Toggle oil managent"},
  })

end


return M

