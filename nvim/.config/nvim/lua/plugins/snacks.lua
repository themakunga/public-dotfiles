local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/folke/snacks.nvim' },
  })

  --@module 'snacks'
  local ok, Snacks = pcall(require, 'snacks')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] Snacks ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local logo = [[
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⢀⣀⠀⠀⣤⠀⢠⡄⢀⣤⣤⡀⢀⡀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣤⠴⠆⣴⠟⠛⢷⡌⢷⣼⠃⠀⠀⣿⣤⣼⡇⣿⠁⠈⢻⣼⡇⠀⣸⠀⣿⡄⢰⡆⣶⢤⣄⡀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡷⠶⠆⣿⡀⠀⣼⢇⡾⢻⣆⠀⠀⣿⠀⢸⡇⢿⣄⣠⡿⠹⣇⠀⣿⠀⡇⠻⣼⡇⣿⠀⠈⣷⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠈⠛⠛⠋⠈⠁⠀⠉⠀⠀⠀⠀⠀⠀⠀⠉⠉⠀⠀⠉⠉⠉⠀⠃⠀⠙⠇⠿⢤⣤⡿⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣤⣤⣶⣶⣶⣿⣿⣿⣿⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽⣛⣫⣤⣤⣤⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⣀⣤⣴⡶⠾⠶⠶⠄⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣇⠀⠀⠀⠈⠉⠙⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⡀⠀⢀⣴⣿⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠁⣤⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿⡿⠟⢿⡿⠛⡛⢿⣿⡇⣴⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣧⣹⣿⣦⣄⠀⠀⠀⠀⠀⠘⢿⣿⣿⣯⣭⣾⣷⣿⣿⣶⣾⣿⣶⣤⣾⡿⠃⠀⠀⠀⠀⢀⣠⡄⣼⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣟⢿⣿⣯⢀⣀⢤⡀⠀⠀⡀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡁⠀⠀⠀⢀⡰⣶⣶⣿⣿⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣷⡻⣿⣶⡎⢿⡿⢛⣭⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⣤⠀⣈⣤⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⡘⢿⠿⣃⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣾⣭⣽⣭⠁⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⡄⢻⣿⣿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡏⣿⣿⣿⡰⣬⡛⢿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⣵⣿⣫⣿⣿⣿⣿⣿⣿⣭⢾⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡿⣿⣿⣷⠙⣿⡞⣿⣿⣿⣿⣿⣿⣿⡟⣿⣿⣿⣿⣾⣻⣿⣿⣿⣿⣿⣿⣿⣽⣾⣷⢟⣼⠇⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢘⡻⣿⣿⡇⢻⣿⡗⣾⣿⢷⡜⠛⠿⠟⠛⠛⠿⣿⠈⢉⣿⣟⢱⣿⣿⣿⢿⡟⠉⠀⣿⣿⣿⢹⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣬⣿⣗⢸⣿⢳⣯⠛⣿⣧⣠⠀⠐⢷⢰⡄⠈⢀⣿⣿⣿⡞⠃⠀⣴⢸⡏⠀⣼⣿⣿⣿⢺⡟⠃⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⠟⠉⠘⢿⣯⣛⢷⡝⢛⣻⣦⣄⣠⣤⣀⢀⡤⣴⣿⣿⡧⢀⣴⣶⣶⣶⣿⣿⣷⡶⢰⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠇⠀⠀⠀⠈⣿⣿⡏⣛⣦⣽⣛⡻⣿⣿⣿⣿⣣⣿⣿⣿⡇⣿⣿⣿⣿⠿⠿⣫⣤⡴⣚⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣮⣭⣟⢻⣿⣮⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣵⣿⣿⠛⢿⠟⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⣶⣶⡝⠙⣝⣿⣿⣿⣿⣿⣿⢯⣿⣿⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⠿⠿⠉⠁⠀⣿⣿⡛⣿⣿⣿⣏⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠈⠻⢿⣷⣝⣻⢿⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⣷⣿⣿⣾⣿⣿⢹⣿⠀⠀⠀⣿⣿⠇⠿⠿⠿⠇⢿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠈⠉⠚⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠚⠛⠀⠀⠀⢿⣿⡀⠀⠀⠀⠀⣸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣶⡆⠀⢰⣝⠿⠶⠆⠶⠾⠿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢷⣤⣾⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠻⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ]]

  local dashboard = {
    width = 60,
    row = nil,
    col = nil,
    pane_gap = 4,
    autokeys = '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
    preset = {
      pick = 'telescope.nvim',
      keys = {
        { icon = ' ', key = 'e', desc = 'Open Sidebar Menu', action = '<cmd>NvimTreeFocus<cr>' },
        { icon = ' ', key = 'f', desc = 'Find File', action = ':lua Snacks.dashboard.pick(\'files\')' },
        { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
        { icon = ' ', key = 'g', desc = 'Find Text', action = ':lua Snacks.dashboard.pick(\'live_grep\')' },
        { icon = ' ', key = 'r', desc = 'Recent Files', action = ':lua Snacks.dashboard.pick(\'oldfiles\')' },
        {
          icon = ' ',
          key = 'c',
          desc = 'Config',
          action = ':lua Snacks.dashboard.pick(\'files\', {cwd = vim.fn.stdpath(\'config\')})',
        },
        { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
        { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
      },
      header = logo,
    },
    -- item field formatters
    formats = {
      icon = function(item)
        if item.file and item.icon == 'file' or item.icon == 'directory' then
          return Snacks.dashboard.icon(item.file, item.icon)
        end
        return { item.icon, width = 2, hl = 'icon' }
      end,
      footer = { '%s', align = 'center' },
      header = { '%s', align = 'center' },
      file = function(item, ctx)
        local fname = vim.fn.fnamemodify(item.file, ':~')
        fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
        if #fname > ctx.width then
          local dir = vim.fn.fnamemodify(fname, ':h')
          local file = vim.fn.fnamemodify(fname, ':t')
          if dir and file then
            file = file:sub(-(ctx.width - #dir - 2))
            fname = dir .. '/…' .. file
          end
        end
        local dir, file = fname:match('^(.*)/(.+)$')
        return dir and { { dir .. '/', hl = 'dir' }, { file, hl = 'file' } } or { { fname, hl = 'file' } }
      end,
    },
    sections = {
      { section = 'header' },
      { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
    },
  }

  local opts = {
    gh = { enable = true },
    dashboard = dashboard,
    bigfile = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    picker = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
      notification = {},
    },
  }

  Snacks.setup(opts)

  local map = vim.keymap.set

  -- map('n', '<leader>', function() Snacks. , {desc = ""})
  map('n', '<leader>n', function()
    Snacks.notifier.show_history()
  end, { desc = 'Show notification history' })
end

return M
