---@type vim.lsp.Config
return {
  cmd = { 'terraform-ls', 'serve' },

  filetypes = {
    'terraform',
    'terraform-vars',
    'terraform-stack',
    'terraform-deploy',
    'terraform-search',
    'terraform-policy',
    'terraform-policytest',
  },

  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {
      '.git',
      '.terraform',
    })

    if not root then
      return
    end

    local tofu = vim.fs.find('versions.tofu', {
      path = root,
      upward = false,
    })

    if #tofu > 0 then
      return
    end

    on_dir(root)
  end,
}
