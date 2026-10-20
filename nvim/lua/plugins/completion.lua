-- Native buffer + path completion alongside vim.lsp.completion
-- Buffer words: deferred so LSP gets priority in the popup
-- Path: immediate trigger on path-like prefixes (./  ../  /  ~/)

local M = {}

---@return string
local function word_before_cursor()
  local col = vim.fn.col('.') - 1
  if col == 0 then return '' end
  return vim.api.nvim_get_current_line():sub(1, col):match('[%w_.~/%-]+$') or ''
end

---@param prefix string
---@return boolean
local function is_path(prefix)
  return prefix:match('^%.%.?/') ~= nil
    or prefix:match('^~/') ~= nil
    or prefix:match('^/') ~= nil
end

---@param prefix string
---@return table
local function path_items(prefix)
  local items = {}
  -- getcompletion resolves relative to cwd; also try relative to current file's dir
  local completions = vim.fn.getcompletion(prefix, 'file')
  for _, p in ipairs(completions) do
    table.insert(items, { word = p, kind = ' Path', icase = 1, dup = 0 })
  end
  return items
end

---@param prefix string
---@param curbuf integer
---@return table
local function buf_items(prefix, curbuf)
  if #prefix < 2 then return {} end
  local items, seen = {}, {}
  local low = prefix:lower()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if not vim.api.nvim_buf_is_loaded(buf) then goto continue end
    local is_cur = buf == curbuf
    for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
      for word in line:gmatch('[%w_]+') do
        if #word > #prefix and word:lower():sub(1, #prefix) == low and not seen[word] then
          seen[word] = true
          table.insert(items, {
            word = word,
            kind = is_cur and ' Buf' or '󰈚 Bufs',
            icase = 1,
            dup = 1,
          })
        end
      end
    end
    ::continue::
  end
  return items
end

M.init = function()
  local timer = nil

  -- Path completion: immediate on InsertCharPre for path-starter chars
  vim.api.nvim_create_autocmd('InsertCharPre', {
    group = vim.api.nvim_create_augroup('native_path_completion', { clear = true }),
    desc = 'Native path completion on / and ~',
    callback = function()
      local ch = vim.v.char
      if ch ~= '/' and ch ~= '~' then return end
      vim.schedule(function()
        local prefix = word_before_cursor() .. ch
        if not is_path(prefix) then return end
        local items = path_items(prefix)
        if #items > 0 then
          vim.fn.complete(vim.fn.col('.') - #prefix, items)
        end
      end)
    end,
  })

  -- Buffer word completion: deferred so LSP popup takes priority
  vim.api.nvim_create_autocmd('TextChangedI', {
    group = vim.api.nvim_create_augroup('native_buf_completion', { clear = true }),
    desc = 'Native buffer word completion (fallback when LSP has no popup)',
    callback = function()
      if timer then
        timer:stop()
        timer = nil
      end

      local prefix = word_before_cursor()

      -- path prefixes are handled by InsertCharPre above
      if is_path(prefix) then return end

      local curbuf = vim.api.nvim_get_current_buf()
      local start_col = vim.fn.col('.') - #prefix

      -- 60 ms: enough for most LSP servers to respond; skip if popup already visible
      timer = vim.defer_fn(function()
        timer = nil
        if vim.fn.pumvisible() == 1 then return end
        local items = buf_items(prefix, curbuf)
        if #items > 0 then
          vim.fn.complete(start_col, items)
        end
      end, 60)
    end,
  })
end

return M
