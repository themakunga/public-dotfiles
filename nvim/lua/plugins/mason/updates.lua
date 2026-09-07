local M = {}

local function get_outdated(callback)
  local ok, registry = pcall(require, 'mason-registry')

  if not ok then
    callback({})
    return
  end

  local function query()
    if type(registry.get_all_installed_packages) ~= 'function' then
      callback({})
      return
    end

    local packages = registry.get_all_installed_packages()
    local outdated = {}
    local pending = #packages

    if pending == 0 then
      callback(outdated)
      return
    end

    for _, pkg in ipairs(packages) do
      pkg:check_new_version(function(success)
        if success then
          table.insert(outdated, pkg)
        end

        pending = pending - 1

        if pending == 0 then
          table.sort(outdated, function(a, b)
            return a.name < b.name
          end)

          callback(outdated)
        end
      end)
    end
  end

  -- Mason v2: el registry es lazy, hay que hacer refresh antes de consultarlo
  if type(registry.refresh) == 'function' then
    registry.refresh(query)
  else
    query()
  end
end

local function update_packages(packages)
  if #packages == 0 then
    return
  end

  for _, pkg in ipairs(packages) do
    pkg:install()
  end
end

local function prompt_update(packages)
  local count = #packages

  if count == 0 then
    return
  end

  local names = vim.tbl_map(function(pkg)
    return pkg.name
  end, packages)

  local message = string.format(
    '%d Mason package%s can be updated:\n\n%s',
    count,
    count == 1 and '' or 's',
    table.concat(names, ', ')
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

    update_packages(packages)
  end)
end

function M.check(opts)
  opts = opts or {}

  if #vim.api.nvim_list_uis() == 0 then
    return
  end

  get_outdated(function(outdated)
    if #outdated == 0 then
      if opts.notify then
        vim.notify('Mason packages are up to date', vim.log.levels.INFO, {
          title = 'Mason',
        })
      end

      return
    end

    vim.schedule(function()
      prompt_update(outdated)
    end)
  end)
end

M.setup = function()
  CMD.usrcmd('MasonCheckUpdates', function()
    M.check({
      notify = true,
    })
  end, {
    desc = 'Check Mason package updates',
  })

  CMD.aucmd('MasonUpdateCheck', {
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
