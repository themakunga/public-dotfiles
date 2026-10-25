local M = {}

local ns     = vim.api.nvim_create_namespace('gh_action_versions')
local _cache = {}

local function flush_diags(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  local diags = {}
  for lnum, entry in pairs(_cache[bufnr] or {}) do
    table.insert(diags, {
      lnum     = lnum,
      end_lnum = lnum,
      col      = 0,
      end_col  = 0,
      severity = entry.severity,
      message  = entry.message,
      source   = 'gh-versions',
    })
  end
  vim.diagnostic.set(ns, bufnr, diags)
end

local function is_workflow(bufnr)
  return vim.api.nvim_buf_get_name(bufnr):match('%.github[/\\]workflows[/\\]') ~= nil
end

local function fetch_version(token, owner, repo, ref, bufnr, lnum)
  vim.system({
    'curl', '-sf',
    '-H', 'Authorization: Bearer ' .. token,
    '-H', 'Accept: application/vnd.github+json',
    '-H', 'X-GitHub-Api-Version: 2022-11-28',
    ('https://api.github.com/repos/%s/%s/releases/latest'):format(owner, repo),
  }, { text = true }, function(res)
    if res.code ~= 0 or not res.stdout then return end
    local ok, data = pcall(vim.json.decode, res.stdout)
    if not ok or type(data) ~= 'table' or not data.tag_name then return end
    local latest     = data.tag_name
    local up_to_date = latest == ref
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then return end
      _cache[bufnr] = _cache[bufnr] or {}
      _cache[bufnr][lnum] = {
        severity = up_to_date and vim.diagnostic.severity.INFO or vim.diagnostic.severity.WARN,
        message  = up_to_date
          and ('✓ %s/%s@%s is latest'):format(owner, repo, ref)
          or  ('⬆ %s/%s: %s → %s'):format(owner, repo, ref, latest),
      }
      flush_diags(bufnr)
    end)
  end)
end

local function scan_buffer(bufnr)
  if not is_workflow(bufnr) then return end
  local token = vim.fn.system('gh auth token 2>/dev/null'):gsub('%s+$', '')
  if token == '' then return end
  _cache[bufnr] = {}
  vim.diagnostic.set(ns, bufnr, {})
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for i, line in ipairs(lines) do
    local owner, repo, ref = line:match('uses:%s+([%w%-%.]+)/([%w%-%.]+)@([%w%.%-]+)')
    if owner and repo and ref then
      fetch_version(token, owner, repo, ref, bufnr, i - 1)
    end
  end
end

M.plugin = function()
  vim.diagnostic.config({
    signs = {
      text = {
        [vim.diagnostic.severity.INFO] = '✓',
        [vim.diagnostic.severity.WARN] = '⬆',
      },
    },
    -- virtual_text siempre visible; formato: "✓ owner/repo@ref is latest"
    virtual_text = {
      format = function(d) return d.message end,
      prefix  = '',
    },
    underline = false,
  }, ns)

  vim.api.nvim_create_augroup('gh-action-versions', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
    group    = 'gh-action-versions',
    pattern  = { '*.yml', '*.yaml' },
    callback = function(args) scan_buffer(args.buf) end,
  })

  -- Comando de debug: :GhVersions
  vim.api.nvim_create_user_command('GhVersions', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local diags = vim.diagnostic.get(bufnr, { namespace = ns })
    local cache_count = 0
    for _ in pairs(_cache[bufnr] or {}) do cache_count = cache_count + 1 end
    vim.notify(('[gh-versions] buf=%d cache=%d diags=%d workflow=%s'):format(
      bufnr, cache_count, #diags, tostring(is_workflow(bufnr))
    ), vim.log.levels.INFO)
  end, {})
end

return M
