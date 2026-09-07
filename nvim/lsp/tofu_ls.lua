vim.filetype.add({
  extension = {
    tofu = 'opentofu',
  },
})

---@type vim.lsp.Config
return {
  cmd = { 'tofu-ls', 'serve' },

  filetypes = {
    'terraform',
    'terraform-vars',
    'opentofu',
  },

  root_dir = function(bufnr, on_dir)
    local tofu_file = vim.fs.find(function(name)
      return name:match('%.tofu$') ~= nil
    end, {
      path = vim.api.nvim_buf_get_name(bufnr),
      upward = true,
      type = 'file',
    })

    if #tofu_file == 0 then
      return
    end

    local root = vim.fs.root(bufnr, {
      '.git',
      '.terraform',
    })

    if root then
      on_dir(root)
    end
  end,
}
