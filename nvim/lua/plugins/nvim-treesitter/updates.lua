local M = {}

local function get_installed_revision(language)
  local config = require('nvim-treesitter.config')

  local path = vim.fs.joinpath(config.get_install_dir('parser-info'), language .. '.revision')

  if vim.fn.filereadable(path) ~= 1 then
    return
  end

  local line = vim.fn.readfile(path)

  return line[1]
end

local function needs_update(language)
  local parsers = require('nvim-treesitter.parsers')

  local ts_config = require('nvim-treesitter.config')

  local install = require('nvim-treesitter.install')

  local parser = parsers[language]

  if not parser then
    return false
  end

  local info = parser.install_info

  if not info then
    return false
  end

  -- partern with pinned version

  if info.revision then
    local installed = get_installed_revision(language)

    return installed ~= info.revision
  end

  local queries = vim.fs.joinpath(ts_config.get_install_dir('queries'), language)

  local queries_source = install.get_package_path('runtime', 'queries', language)

  return vim.uv.fs_realpath(queries) ~= vim.uv.fs_realpath(queries_source)
end

local function get_outdated()
  local treesitter = require('nvim-treesitter')

  local installed = treesitter.get_installed()

  local outdated = {}

  for _, language in ipairs(installed) do
    if needs_update(language) then
      table.insert(outdated, language)
    end
  end

  table.sort(outdated)

  return outdated
end

local function update_parsers(parsers)
  if #parsers == 0 then
    return
  end

  require('nvim-treesitter').update(parsers, {
    summary = true,
  })
end

local function prompt_update(parsers)
  local count = #parsers

  if count == 0 then
    return
  end

  local message = string.format(
    '%d Treesitter parser%s can be updated:\n\n%s',
    count,
    count == 1 and '' or 's',
    table.concat(parsers, ', ')
  )

  vim.ui.select({
    'Update',
    'Later',
  }, {
    prompt = message,
  }, function(choice)
    if choice ~= 'Update' then
      return
    end

    update_parsers(parsers)
  end)
end

function M.check(opts)
  opts = opts or {}

  if #vim.api.nvim_list_uis() == 0 then
    return
  end

  local outdated = get_outdated()

  if #outdated == 0 then
    if opts.notify then
      vim.notify('Treesitter parsers are up to date', vim.log.levels.INFO, {
        title = 'Treesitter',
      })
    end

    return
  end

  prompt_update(outdated)
end

M.setup = function()
  CMD.usrcmd('TreesitterCheckUpdates', function()
    M.check({
      notify = true,
    })
  end, {
    desc = 'Check Treesitter parser updates',
  })

  CMD.aucmd('TreesitterUpdateCheck', {
    {
      event = 'VimEnter',
      once = true,

      callback = function()
        vim.schedule(function()
          M.check({
            notify = false,
          })
        end)
      end,
    },
  })
end

return M
