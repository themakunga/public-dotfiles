local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/folke/noice.nvim' },
  })

  local ok, noice = pcall(require, 'noice')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] noice ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = true,
    },
    progress = {
      format_done = {
        { '󰸞 ', hl_group = 'NoiceLspProgressSpinner' },
        { '{data.progress.title} ', hl_group = 'NoiceLspProgressTitle' },
        { '{data.progress.client} ', hl_group = 'NoiceLspProgressClient' },
      },
    },
    hover = {
      enabled = false,
    },
    signature = {
      enabled = false,
    },
    message = {
      enabled = true,
      view = 'mini',
    },
  }

  local routes = {
    {
      view = 'mini',
      filter = { event = 'notify' },
      opts = { title = 'Notify' },
    },
  }

  local opts = {
    cmdline = { enable = false },
    messages = { enable = false },
    popupmenu = { enable = false },
    notify = {
      enable = true,
      view = 'notify',
    },
    views = {
      mini = {
        win_options = {
          winblend = 0,
        },
        position = {
          row = -3,
        },
      },
    },
    lsp = lsp,
    routes = routes,
  }

  noice.setup(opts)
end

return M
