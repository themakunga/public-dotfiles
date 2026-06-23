local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },
  })

  --@module 'render_markdown'
  local ok, render_markdown = pcall(require, 'render-markdown')

  if not ok then
    vim.notify("[CHECK REQUIRE FAILED] render_markdown " .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  --@type render_markdown.SetupOps
  local opts = {
    completions = { lsp = { enabled = true } }
  }

  render_markdown.setup(opts)


  vim.keymap.set('n', '<leader>m', '<cmd>RenderMarkdown<cr>', { desc = "Render Markdown enable" })
  vim.keymap.set('n', '<leader>me', '<cmd>RenderMarkdown enable<cr>', { desc = "Render Markdown enable" })
  vim.keymap.set('n', '<leader>mbe', '<cmd>RenderMarkdown buf_enable<cr>', { desc = "Render Markdown buffer enable" })
  vim.keymap.set('n', '<leader>md', '<cmd>RenderMarkdown disable<cr>', { desc = "Render Markdown disable" })
  vim.keymap.set('n', '<leader>mbd', '<cmd>RenderMarkdown buf_disable<cr>', { desc = "Render Markdown buffer disable" })
  vim.keymap.set('n', '<leader>mbt', '<cmd>RenderMarkdown buf_toggle<cr>', { desc = "Render Markdown toggle" })
  vim.keymap.set('n', '<leader>mt', '<cmd>RenderMarkdown toggle<cr>', { desc = "Render Markdown buffer toggle" })
  vim.keymap.set('n', '<leader>mg', '<cmd>RenderMarkdown get<cr>', { desc = "Render Markdown get" })
  vim.keymap.set('n', '<leader>mp', '<cmd>RenderMarkdown preview<cr>', { desc = "Render Markdown preview" })
  vim.keymap.set('n', '<leader>ml', '<cmd>RenderMarkdown log<cr>', { desc = "Render Markdown log" })
  vim.keymap.set('n', '<leader>mx', '<cmd>RenderMarkdown expand<cr>', { desc = "Render Markdown expand" })
  vim.keymap.set('n', '<leader>md', '<cmd>RenderMarkdown debug<cr>', { desc = "Render Markdown debug" })
  vim.keymap.set('n', '<leader>mc', '<cmd>RenderMarkdown config<cr>', { desc = "Render Markdown config" })
end

return M
